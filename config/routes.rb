Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      post "auth/login", to: "auth#login"

      post "sleep_records/clock_in", to: "sleep_records#clock_in"
    end
  end
end
