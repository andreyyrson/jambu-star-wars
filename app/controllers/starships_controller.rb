# app/controllers/starships_controller.rb

class StarshipsController < ApplicationController
  before_action :set_starship, only: %i[ show favorite ]

  # GET /starships.json
  def index
    @starships = Starship.all
    render json: @starships
  end

  # GET /starships/1.json
  def show
    render json: @starship
  end

  # POST /starships/:id/favorite
  # Ação atualizada para exigir o favorites_list_id
  def favorite
    starship = @starship # O @starship já está carregado pelo before_action
    list_id = params[:favorites_list_id]
    
    unless list_id.present?
      return render json: { error: "O parâmetro 'favorites_list_id' é obrigatório para favoritar. Por favor, especifique a lista." }, status: :bad_request
    end

    favorites_list = FavoritesList.find(list_id)

    @favorite = starship.favorites.new(favorites_list_id: favorites_list.id)

    if @favorite.save
      render json: @favorite, status: :created
    else
      render json: { errors: @favorite.errors.full_messages }, status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Recurso (Lista de Favoritos) não encontrado" }, status: :not_found
  end

  private
    def set_starship
      @starship = Starship.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      render json: { error: "Nave Estelar não encontrada" }, status: :not_found
    end
end