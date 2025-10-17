require 'httparty'

class SearchController < ApplicationController  
  SWAPI_BASE_URL = 'https://swapi.dev/api/'
  SWAPI_PEOPLE_ENDPOINT = 'people/'
  
  def index
    query = params[:query].to_s.strip
    @results = []

    unless query.present?
      return render json: { results: [] }, status: :ok if request.format.json?
      return 
    end

    local_results = search_local_models(query)
    @results.concat(local_results)

    if @results.empty? || local_results.count < 3
        Rails.logger.info "Buscando na SWAPI..."
        api_results = api_search(query)
        @results.concat(api_results)
    end
    
    respond_to do |format|
        format.json { render json: { results: @results.uniq }, status: :ok }
        format.html { render :index }
    end
  end

  # NOVO: AÇÃO PARA PERSISTIR DADOS DA SWAPI NO DB LOCAL
  def save_external
    name = params[:name]
    model_type = params[:type] 

    unless ['Person', 'Planet', 'Starship'].include?(model_type)
      return render json: { error: "Tipo de modelo inválido para persistência." }, status: :unprocessable_entity
    end

    model_class = model_type.constantize
    @record = model_class.find_or_initialize_by(name: name) 

    if @record.new_record?
      if @record.save
        render json: { id: @record.id, name: @record.name, type: model_type }, status: :created
      else
        render json: { errors: @record.errors.full_messages, error: "Falha ao salvar o registro." }, status: :unprocessable_entity
      end
    else
      render json: { id: @record.id, name: @record.name, type: model_type, message: "Item já existia no DB." }, status: :ok
    end
  rescue NameError
    render json: { error: "Tipo de modelo desconhecido." }, status: :unprocessable_entity
  end
  
  private
  
  def search_local_models(query)
    db_adapter = ActiveRecord::Base.connection.adapter_name.downcase
    case_insensitive_like = (db_adapter == 'sqlite') ? 'LIKE' : 'ILIKE'
    search_pattern = "%#{query}%"
    results = []
    
    Person.where("name #{case_insensitive_like} ?", search_pattern).each do |p|
      results << { id: p.id, name: p.name, model: 'Person', type: 'Personagem' }
    end

    Planet.where("name #{case_insensitive_like} ?", search_pattern).each do |pl|
      results << { id: pl.id, name: pl.name, model: 'Planet', type: 'Planeta' }
    end

    Starship.where("name #{case_insensitive_like} ?", search_pattern).each do |s|
      results << { id: s.id, name: s.name, model: 'Starship', type: 'Nave Estelar' }
    end
    
    results
  end

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
            model: 'SWAPI Character',
            type: 'SWAPI Character'
          }
        end
      end
    end
    return results
  rescue JSON::ParserError, Errno::ECONNREFUSED => e
    Rails.logger.error "Falha na busca SWAPI: #{e.message}"
    return []
  end
end