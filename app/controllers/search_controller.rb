class SearchController < ApplicationController  
  SWAPI_BASE_URL = 'https://swapi.dev/api/'
  SWAPI_PEOPLE_ENDPOINT = 'people/'
  def index
    query = params[:query].to_s.strip
    @results = []

    return unless query.present?

    is_external_only_search = ["luke skywalker", "r2-d2"].include?(query.downcase)
    
    if is_external_only_search
        puts "Termo conhecido (SWAPI). Buscando diretamente na API..."
        api_results = api_search(query)
        @results.concat(api_results)
    else
        db_adapter = ActiveRecord::Base.connection.adapter_name.downcase
        
        case_insensitive_like = (db_adapter == 'sqlite') ? 'LIKE' : 'ILIKE'
        
        search_pattern = "%#{query}%"

        people = Person.where("name #{case_insensitive_like} ?", search_pattern)
        planets = Planet.where("name #{case_insensitive_like} ?", search_pattern)
        starships = Starship.where("name #{case_insensitive_like} ?", search_pattern)


        @results.concat(people.map { |p| { id: p.id, name: p.name, model: 'person', type: 'Personagem' } })
        @results.concat(planets.map { |pl| { id: pl.id, name: pl.name, model: 'planet', type: 'Planeta' } })
        @results.concat(starships.map { |s| { id: s.id, name: s.name, model: 'starship', type: 'Nave Estelar' } })
        
        if @results.empty?
            puts "Nenhum resultado local. Buscando na SWAPI (Fallback)..."
            api_results = api_search(query)
            @results.concat(api_results)
        end
    end
    
     #utilizei IA para me ajudar nessa requisiçao de formato AJAX Garante que a resposta seja JSON para o Front-end AJAX
    if request.xhr? || request.format.json?
        render json: @results
    else
      render :index
    end
  end
  
  private

  def api_search(query)
    results = []
    
    url = "#{SWAPI_BASE_URL}#{SWAPI_PEOPLE_ENDPOINT}?search=#{CGI.escape(query)}"
    
    response = HTTParty.get(url)
    
    if response.code == 200
      data = JSON.parse(response.body)
      
      if data["results"].is_a?(Array)
        data["results"].each do |item|
          results << {
            id: item["url"].split('/').last(2).join('-'), 
            name: item["name"],
            model: 'external',
            type: 'SWAPI Character'
          }
        end
      else
         Rails.logger.error "SWAPI Response Missing 'results' key or it is not an array: #{data.keys.join(', ')}"
      end
    else
      Rails.logger.error "SWAPI API call failed with code: #{response.code}"
    end

    return results
  rescue JSON::ParserError, Errno::ECONNREFUSED => e
    Rails.logger.error "Failed to parse SWAPI response or connect: #{e.message}"
    return []
  end

end
