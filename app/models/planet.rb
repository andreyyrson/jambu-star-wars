class Planet < ApplicationRecord
  has_many :favorites, as: :favoritable, dependent: :destroy
end
