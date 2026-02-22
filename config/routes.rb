Rails.application.routes.draw do

    # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
    # Can be used by load balancers and uptime monitors to verify that the app is live.
  # Defines the root path route ("/")
  # root "posts#index"
  namespace :api do
    namespace :v1 do
      resources :conversations, only: [ :create, :show, :index ]
      resources :messages, only: [ :create ]
    end
  end
end
