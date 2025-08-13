Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      post "auth/login", to: "auth#login"

      # sleep_records
      get "sleep_records/friends_weekly", to: "sleep_records#friends_weekly"
      get "sleep_records", to: "sleep_records#index"
      post "sleep_records/clock_in", to: "sleep_records#clock_in"
      post "sleep_records/clock_out", to: "sleep_records#clock_out"

      # follows
      resources :follows, only: [ :create, :destroy ]
    end
  end
end
