Rails.application.routes.draw do
  
 
  resources :favorites_lists, only: [:index, :show, :create]

  # Rotas ORIGINAIS de ITENS FAVORITOS
  resources :favorites, only: [:index, :create, :destroy] do
    get 'by_type/:type', on: :collection, action: :by_type
  end

  resources :starships, only: [:index, :show] do
    post 'favorite', on: :member
  end
  resources :planets, only: [:index, :show] do
    post 'favorite', on: :member
  end
  resources :people, only: [:index, :show] do
    post 'favorite', on: :member
  end
  
  get 'search/index'
  
  get "up" => "rails/health#show", as: :rails_health_check
end