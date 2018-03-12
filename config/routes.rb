Rails.application.routes.draw do
  devise_for :users
  root to: 'pages#home'
  get 'dashboard', to: 'pages#dashboard', as: :dashboard
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  resources :users, only: [:show, :edit, :update]
  get 'routes/:id/get_image', to: 'routes#get_image', as: :image

  resources :routes, only: [:index, :show, :edit, :update, :new, :create] do
    get 'download', to: 'routes#download_gpx', as: :download
    resources :reviews, only: [:create]
    resources :favourites, only: [:create, :destroy]
  end

  put 'routes/:id/set_ascent_and_distance', to: 'routes#set_ascent_and_distance'
end
