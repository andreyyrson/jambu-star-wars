class PeopleController < ApplicationController
  # O before_action set_person carregará o Personagem para as ações show e favorite
  before_action :set_person, only: %i[ show favorite ]

  # GET /people.json
  def index
    @people = Person.all
    render json: @people
  end

  # GET /people/1.json
  def show
    render json: @person
  end

  # POST /people/:id/favorite
  # Ação atualizada para exigir o favorites_list_id
  def favorite
    person = @person
    list_id = params[:favorites_list_id]
    
    unless list_id.present?
      return render json: { error: "O parâmetro 'favorites_list_id' é obrigatório para favoritar. Por favor, especifique a lista." }, status: :bad_request
    end

    favorites_list = FavoritesList.find(list_id)

    @favorite = person.favorites.new(favorites_list_id: favorites_list.id)

    if @favorite.save
      render json: @favorite, status: :created
    else
      render json: { errors: @favorite.errors.full_messages }, status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Recurso (Lista de Favoritos) não encontrado" }, status: :not_found
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_person
      @person = Person.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      render json: { error: "Personagem não encontrado" }, status: :not_found
    end

end
