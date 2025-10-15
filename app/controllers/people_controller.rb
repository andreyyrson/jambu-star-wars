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
    person = @person # O @person já está carregado
    list_id = params[:favorites_list_id]
    
    # 1. Validação: Checa se o ID da lista foi enviado
    unless list_id.present?
      return render json: { error: "O parâmetro 'favorites_list_id' é obrigatório para favoritar. Por favor, especifique a lista." }, status: :bad_request
    end

    # 2. Encontra a lista. Se não encontrar, o resgate abaixo trata o erro.
    favorites_list = FavoritesList.find(list_id)

    # 3. Cria o novo Favorite com a chave da lista
    # O favorito é criado na lista correta (favorites_list_id) e aponta para o Person (@person)
    @favorite = person.favorites.new(favorites_list_id: favorites_list.id)

    if @favorite.save
      # Sucesso: Retorna o novo registro Favorite (status 201)
      render json: @favorite, status: :created
    else
      # Falha: Retorna erros (ex: item já favoritado na mesma lista)
      render json: { errors: @favorite.errors.full_messages }, status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordNotFound
    # Este resgate captura o erro se o ID da Lista não existir
    render json: { error: "Recurso (Lista de Favoritos) não encontrado" }, status: :not_found
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_person
      @person = Person.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      # Garante que, se o ID for inválido, retornaremos um erro 404
      render json: { error: "Personagem não encontrado" }, status: :not_found
    end

end
