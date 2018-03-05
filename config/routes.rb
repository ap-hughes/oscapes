Rails.application.routes.draw do
  devise_for :users
  root to: 'pages#home'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  resources :users, only: [:show, :edit, :update] do
    resources :favourites, only: [:create, :destroy]
  end

  resources :routes, only: [:index, :show] do
    resources :reviews, only: [:create]
  end
end
