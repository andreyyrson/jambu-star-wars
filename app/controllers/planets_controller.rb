# app/controllers/planets_controller.rb

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
  # Ação atualizada para exigir o favorites_list_id
  def favorite
    planet = @planet # O @planet já está carregado pelo before_action
    list_id = params[:favorites_list_id]
    
    unless list_id.present?
      return render json: { error: "O parâmetro 'favorites_list_id' é obrigatório para favoritar. Por favor, especifique a lista." }, status: :bad_request
    end

    favorites_list = FavoritesList.find(list_id)

    @favorite = planet.favorites.new(favorites_list_id: favorites_list.id)

    if @favorite.save
      render json: @favorite, status: :created
    else
      render json: { errors: @favorite.errors.full_messages }, status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Recurso (Lista de Favoritos) não encontrado" }, status: :not_found
  end

  private
    def set_planet
      @planet = Planet.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      render json: { error: "Planeta não encontrado" }, status: :not_found
    end
end