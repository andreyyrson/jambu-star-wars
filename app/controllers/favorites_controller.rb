class FavoritesController < ApplicationController

  def create
    favorite_list = FavoriteList.find_by(id: params[:favorite_list_id])
    
    unless favorite_list
      return render json: { error: "Lista de Favoritos não encontrada." }, status: :not_found
    end

    @favorite = Favorite.new(
      favorite_list: favorite_list,
      favoritable_id: params[:favoritable_id],
      favoritable_type: params[:favoritable_type]
    )

    if @favorite.save
      respond_to do |format|
        format.html { redirect_back fallback_location: root_path, notice: "Item adicionado!" }
        format.json { render json: @favorite, status: :created } 
      end
    else
      respond_to do |format|
        format.html { redirect_back fallback_location: root_path, alert: "Erro: #{@favorite.errors.full_messages.to_sentence}", status: :unprocessable_entity }
        format.json { render json: { errors: @favorite.errors.full_messages, message: @favorite.errors.full_messages.to_sentence }, status: :unprocessable_entity } 
      end
    end
  end

  def destroy
    @favorite = Favorite.find_by!(
        favorite_list_id: params[:favorite_list_id],
        favoritable_id: params[:favoritable_id],
        favoritable_type: params[:favoritable_type]
    )
    @favorite.destroy
    respond_to do |format|
      format.html { redirect_back fallback_location: root_path, notice: "Item removido da lista." }
      format.json { head :no_content } # 204 No Content
    end
  rescue ActiveRecord::RecordNotFound => e
    respond_to do |format|
      format.html { redirect_back fallback_location: root_path, alert: "Favorito não encontrado." }
      format.json { render json: { error: "Favorito não encontrado: #{e.message}" }, status: :not_found }
    end
  end
end