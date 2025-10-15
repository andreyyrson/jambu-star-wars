Rails.application.routes.draw do
  
 
  resources :favorites_lists, only: [:index, :show, :create]

  # Rotas ORIGINAIS de ITENS FAVORITOS
  resources :favorites, only: [:index, :create, :destroy] do
    # Rota customizada para filtrar favoritos por tipo
    get 'by_type/:type', on: :collection, action: :by_type
  end

  # Rotas dos Recursos com Ação Personalizada para FAVORITAR
  # Inclui a rota aninhada 'POST /recurso/:id/favorite'
  resources :starships, only: [:index, :show] do
    post 'favorite', on: :member
  end
  resources :planets, only: [:index, :show] do
    post 'favorite', on: :member
  end
  resources :people, only: [:index, :show] do
    post 'favorite', on: :member
  end
  
  # Funcionalidade 1: Busca Unificada
  # Mantém o search/index (o search/show foi removido por ser desnecessário)
  get 'search/index'
  
  get "up" => "rails/health#show", as: :rails_health_check
end