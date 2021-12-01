Rails.application.routes.draw do
  devise_for :users
  root to: 'pages#home'
  get 'ranking', to: 'pages#ranking'
  resources :events do
    resources :transactions, only: [:new, :create, :edit, :update, :destroy]
  end
  resources :users
  resources :offers

  require "sidekiq/web"
  authenticate :user, ->(user) { user.admin? } do
    mount Sidekiq::Web => '/sidekiq'
  end
end
