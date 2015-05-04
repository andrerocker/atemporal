Rails.application.routes.draw do
  root to: "jobs#home"

  resources :jobs, only: [:create, :index, :show] do
    member do
      patch :callback, action: :running
      delete :callback, action: :finished
    end
  end
end
