Rails.application.routes.draw do
  root "status#index"
  resources :users, only: [:show]
  resources :transactions, only: [:index, :show, :create]
  get 'payment_response', to: 'transactions#payment_response', as: :payment_response
end
