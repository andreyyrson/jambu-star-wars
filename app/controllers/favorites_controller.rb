class FavoritesController < ApplicationController
  # GET /favorites.json (Lista todos os favoritos)
  # A lista de todos os favoritos é útil para ver todos os itens de todas as listas combinados
  def index
    # Note: Você pode querer mudar isso para Favorite.where(favorites_list_id: nil) se quiser filtrar itens soltos
    @favorites = Favorite.all 
    # Inclui o item original (Person, Planet, Starship)
    render json: @favorites, include: :favoritable
  end

  # NOVO MÉTODO: GET /favorites/by_type/:type (Funcionalidade 3)
  # Exemplo: /favorites/by_type/Starship
  def by_type
    # Normaliza o tipo (ex: 'starship' -> 'Starship')
    favorite_type = params[:type].singularize.capitalize
    
    # Busca e inclui os dados do item original
    @favorites = Favorite.where(favoritable_type: favorite_type)
                         .includes(:favoritable)
                         .all

    if @favorites.any?
      render json: @favorites, include: :favoritable
    else
      render json: { message: "Nenhum favorito encontrado para o tipo: #{favorite_type}" }, status: :ok
    end
  end

  # POST /favorites.json (Cria um novo favorito - Marcar)
  # Este endpoint pode ser usado se você estiver favoritando fora de um recurso específico, 
  # mas o POST /recurso/:id/favorite é o método mais comum na sua API.
  def create
    # Adicionei a verificação de favorites_list_id aqui, caso você use este endpoint
    @favorite = Favorite.new(favorite_params) 

    if @favorite.save
      render json: @favorite, status: :created
    else
      render json: @favorite.errors, status: :unprocessable_entity
    end
  end

  # DELETE /favorites/1.json (Remove um favorito - Desmarcar)
  def destroy
    Favorite.find(params[:id]).destroy!
    head :no_content
  end

  private
    # Parâmetros permitidos: o TIPO, o ID do item sendo favoritado e o ID da LISTA
    def favorite_params
      params.require(:favorite).permit(:favoritable_type, :favoritable_id, :favorites_list_id)
    end
end