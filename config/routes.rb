Rails.application.routes.draw do
  # ActionCable
  mount ActionCable.server => "/cable"

  post "/players", to: "players#create"
  delete "/players/:id", to: "players#delete"

  post "/rooms", to: "rooms#create"
  get "/rooms", to: "rooms#index"
  post "/rooms/:id/join", to: "rooms#join"
  post "/rooms/:id/leave", to: "rooms#leave"
  post "/rooms/:id/start", to: "rooms#start"
  post "/rooms/:id/action", to: "rooms#action"
  post "/rooms/:id/next-phase", to: "rooms#next_phase"
  post "/rooms/:id/end", to: "rooms#end"
end
