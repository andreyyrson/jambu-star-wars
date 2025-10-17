# app/models/favorite.rb

class Favorite < ApplicationRecord
  # O item real (Person, Planet, Starship)
  belongs_to :favoritable, polymorphic: true
  
  # CORREÇÃO: A qual lista este favorito pertence
  belongs_to :favorite_list 
  
  # Validação para evitar favoritos duplicados na mesma lista
  validates :favoritable_id, uniqueness: { scope: [:favoritable_type, :favorite_list_id], message: "já está nesta lista." }
end