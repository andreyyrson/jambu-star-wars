# db/migrate/20251016211502_add_favorite_list_ref_to_favorites.rb (CORRIGIDO)

class AddFavoriteListRefToFavorites < ActiveRecord::Migration[7.1]
  def change
    # Alterado para null: true para permitir que linhas existentes não falhem.
    add_reference :favorites, :favorite_list, null: true, foreign_key: true 
  end
end