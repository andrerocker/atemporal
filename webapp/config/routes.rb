Rails.application.routes.draw do
  root to: "jobs#home"

  resources :jobs, only: [:create, :index, :show] do
    member do
      get :callback
    end
  end
end
