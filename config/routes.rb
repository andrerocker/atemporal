Rails.application.routes.draw do
  resources :jobs, only: [:create, :index, :show] do
    member do
      get :callback
    end
  end
end
