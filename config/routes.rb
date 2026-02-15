Rails.application.routes.draw do
  devise_for :users,
  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
    defaults: { format: :json },
      path: "",
      path_names: {
        sign_in: "login",
        sign_out: "logout",
        registration: "signup"
      }
  # Defines the root path route ("/")
  # root "posts#index"
  namespace :api do
    namespace :v1 do
      resources :conversations, only: [:create, :show, :index]
      resources :messages, only: [:create]
    end
  end
end
