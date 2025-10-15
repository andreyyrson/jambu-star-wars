class AddFavoritesListRefToFavorites < ActiveRecord::Migration[7.1]
  def change
    add_reference :favorites, :favorites_list, null: true, foreign_key: true
  end
end
