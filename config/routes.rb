Rails.application.routes.draw do
  post "/players", to: "players#create"
  delete "/players/:id", to: "players#delete"

  post "/rooms", to: "rooms#create"
  get "/rooms", to: "rooms#index"
end
