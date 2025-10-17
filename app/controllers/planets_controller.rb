class PlanetsController < ApplicationController
  before_action :set_planet, only: %i[ show favorite ]

  # GET /planets.json
  def index
    @planets = Planet.all
    render json: @planets
  end

  # GET /planets/1.json
  def show
    render json: @planet
  end

  # POST /planets/:id/favorite
  def favorite
    list_id = favorite_params[:favorites_list_id]
    
    unless list_id.present?
      return render json: { error: "O parâmetro 'favorites_list_id' é obrigatório para favoritar." }, status: :bad_request
    end

    favorites_list = FavoritesList.find(list_id)

    @favorite = @planet.favorites.new(favorites_list: favorites_list) 

    if @favorite.save
      render json: @favorite, status: :created
    else
      render json: { error: @favorite.errors.full_messages.to_sentence }, status: :unprocessable_entity
    end
    
  rescue ActiveRecord::RecordNotFound
    render json: { error: "A Lista de Favoritos (ID: #{list_id}) não foi encontrada." }, status: :not_found
  rescue => e
    Rails.logger.error "Erro inesperado ao favoritar: #{e.message}"
    render json: { error: "Erro interno ao processar a requisição." }, status: :internal_server_error
  end

  private
    def set_planet
      @planet = Planet.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      render json: { error: "Planeta não encontrado" }, status: :not_found
    end
    
    def favorite_params
      params.permit(:favorites_list_id)
    end
end
