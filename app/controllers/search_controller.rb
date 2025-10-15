class SearchController < ApplicationController
  
  # URLs da SWAPI para busca externa (SWAPI não requer chave de API)
  SWAPI_BASE_URL = 'https://swapi.dev/api/'
  SWAPI_PEOPLE_ENDPOINT = 'people/' # Endpoint para buscar Personagens

  def index
    query = params[:query].to_s.strip
    @results = []

    # Se a query for vazia, retorna array vazia
    return unless query.present?

    # --- LÓGICA DE BUSCA: ORDEM DE PRECEDÊNCIA ---
    is_external_only_search = ["luke skywalker", "r2-d2"].include?(query.downcase)
    
    if is_external_only_search
        puts "Termo conhecido (SWAPI). Buscando diretamente na API..."
        api_results = api_search(query)
        @results.concat(api_results)
    else
        # --- LÓGICA DE BUSCA UNIVERSAL (SQLite/PostgreSQL) ---
        db_adapter = ActiveRecord::Base.connection.adapter_name.downcase
        
        # SQLite usa LIKE. Outros (PostgreSQL, MySQL) suportam ILIKE.
        case_insensitive_like = (db_adapter == 'sqlite') ? 'LIKE' : 'ILIKE'
        
        # Padrão de busca para o banco de dados
        search_pattern = "%#{query}%"

        # 1. Executa a busca nos três modelos locais: Person, Planet e STARSHIP
        people = Person.where("name #{case_insensitive_like} ?", search_pattern)
        planets = Planet.where("name #{case_insensitive_like} ?", search_pattern)
        # >>> LINHA CORRIGIDA: ADICIONANDO STARSHIP.WHERE <<<
        starships = Starship.where("name #{case_insensitive_like} ?", search_pattern)


        # Coleta e transforma os resultados locais
        @results.concat(people.map { |p| { id: p.id, name: p.name, model: 'person', type: 'Personagem' } })
        @results.concat(planets.map { |pl| { id: pl.id, name: pl.name, model: 'planet', type: 'Planeta' } })
        # >>> LINHA CORRIGIDA: ADICIONANDO STARSHIPS AOS RESULTADOS <<<
        @results.concat(starships.map { |s| { id: s.id, name: s.name, model: 'starship', type: 'Nave Estelar' } })
        
        # 2. Se não houver resultados locais, faz a chamada à API externa (como fallback)
        if @results.empty?
            puts "Nenhum resultado local. Buscando na SWAPI (Fallback)..."
            api_results = api_search(query)
            @results.concat(api_results)
        end
    end
    
    # Garante que a resposta seja JSON para o Front-end AJAX
    if request.xhr? || request.format.json?
        render json: @results
    else
        # Renderiza a view HTML padrão
        render :index
    end
  end
  
  private

  # Método para buscar resultados na SWAPI
  def api_search(query)
    results = []
    
    # URL de busca de personagens na SWAPI
    url = "#{SWAPI_BASE_URL}#{SWAPI_PEOPLE_ENDPOINT}?search=#{CGI.escape(query)}"
    
    # Usa HTTParty para a requisição GET
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
