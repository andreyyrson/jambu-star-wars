# config/routes.rb

Rails.application.routes.draw do
  
  # Rotas para FavoriteLists (index, show, create, destroy)
  resources :favorite_lists, only: [:index, :show, :create, :destroy] 
  
  # Rotas para Favorites (create, destroy)
  resources :favorites, only: [:create, :destroy] 
  
  # Rotas de itens SWAPI (apenas leitura)
  resources :people, only: [:index, :show]
  resources :planets, only: [:index, :show]
  resources :starships, only: [:index, :show]

  # Busca genérica (GET)
  get 'search/index'
  
  # Rota POST para a função de salvar item da SWAPI no DB local
  post 'search/save_external', to: 'search#save_external' 

  # CORREÇÃO CRÍTICA: Define a página de busca como a raiz da aplicação.
  root 'search#index' 
  
  get "up" => "rails/health#show", as: :rails_health_check
end