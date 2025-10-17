
class FavoriteListsController < ApplicationController

  def index
    @favorite_lists = FavoriteList.includes(favorites: :favoritable).all
    
    respond_to do |format|
      format.html 
      
      format.json { 
        render json: @favorite_lists, 
               include: { favorites: { include: :favoritable } }, 
               status: :ok 
      }
    end
  end

  def show
    @favorite_list = FavoriteList.find(params[:id])
  end

  def create
    @favorite_list = FavoriteList.new(favorite_list_params)
    if @favorite_list.save
      respond_to do |format|
        format.html { redirect_to root_path, notice: 'Lista criada com sucesso!' }
        format.json { render json: @favorite_list, status: :created }
      end
    else
      respond_to do |format|
        format.html { redirect_to root_path, alert: @favorite_list.errors.full_messages.to_sentence, status: :unprocessable_entity }
        format.json { render json: { errors: @favorite_list.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end
  
  def destroy
    @favorite_list = FavoriteList.find(params[:id])
    
    @favorite_list.destroy
    
    respond_to do |format|
      format.html { redirect_to root_path, notice: 'Lista deletada com sucesso.' }
      format.json { head :no_content } # Status 204: Sucesso, mas sem conteúdo para retornar.
    end
    
  rescue ActiveRecord::RecordNotFound
    respond_to do |format|
      format.html { redirect_to root_path, alert: "Lista não encontrada." }
      format.json { render json: { error: "Lista não encontrada." }, status: :not_found } # Status 404
    end
  end

  private

  def favorite_list_params
    params.require(:favorite_list).permit(:name)
  end
end