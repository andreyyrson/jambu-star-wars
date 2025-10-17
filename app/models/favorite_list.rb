# app/models/favorite_list.rb

class FavoriteList < ApplicationRecord
  has_many :favorites, dependent: :destroy
    validates :name, presence: true
end
