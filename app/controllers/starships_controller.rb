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
  def favorite
    # 1. Valida e acessa o ID da lista através de strong parameters
    list_id = favorite_params[:favorites_list_id]
    
    unless list_id.present?
      # Retorna 400 Bad Request se o ID da lista estiver faltando
      return render json: { error: "O parâmetro 'favorites_list_id' é obrigatório para favoritar." }, status: :bad_request
    end

    favorites_list = FavoritesList.find(list_id)

    @favorite = @starship.favorites.new(favorites_list: favorites_list) 

    if @favorite.save
      render json: @favorite, status: :created
    else
      # Erro de validação
      render json: { error: @favorite.errors.full_messages.to_sentence }, status: :unprocessable_entity
    end
    
  rescue ActiveRecord::RecordNotFound
    render json: { error: "A Lista de Favoritos (ID: #{list_id}) não foi encontrada." }, status: :not_found
  rescue => e
    Rails.logger.error "Erro inesperado ao favoritar: #{e.message}"
    render json: { error: "Erro interno ao processar a requisição." }, status: :internal_server_error
  end

  private
    def set_starship
      @starship = Starship.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      render json: { error: "Nave Estelar não encontrada" }, status: :not_found
    end
    
    def favorite_params
      params.permit(:favorites_list_id)
    end
end
