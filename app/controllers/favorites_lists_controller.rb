class FavoritesListsController < ApplicationController
  before_action :set_favorites_list, only: [:show]

  # GET /favorites_lists
  def index
    @lists = FavoritesList.all
    # Opcional: Aqui você faria a filtragem por usuário, se houvesse autenticação.
    render json: @lists
  end

  # GET /favorites_lists/1
  def show
    # Ao retornar uma lista, incluímos todos os Favorites (e os itens favoritos) que pertencem a ela
    render json: @favorites_list, include: { favorites: { include: :favoritable } }
  end

  # POST /favorites_lists
  def create
    @list = FavoritesList.new(favorites_list_params)

    if @list.save
      render json: @list, status: :created
    else
      render json: @list.errors, status: :unprocessable_entity
    end
  end

  private

  def set_favorites_list
    @favorites_list = FavoritesList.find(params[:id])
  end

  def favorites_list_params
    params.require(:favorites_list).permit(:name)
  end
end
