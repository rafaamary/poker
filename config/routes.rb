Rails.application.routes.draw do
  post "/players", to: "players#create"
  delete "/players/:id", to: "players#delete"
end
