class PlayersController < ApplicationController
  def create
    player = Player.create!(player_params)

    render json: PlayerSerializer.new(player).as_json, status: :created
  end

  private

  def player_params
    params.permit(:name)
  end
end
