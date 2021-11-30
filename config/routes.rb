Rails.application.routes.draw do
  devise_for :users
  root to: 'pages#home'
  resources :events do
    resources :transactions, only: [:new, :create, :destroy]
  end
  resources :users
  resources :offers
end
