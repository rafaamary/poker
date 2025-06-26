Rails.application.routes.draw do
  post "/players", to: "players#create", as: :players
end
