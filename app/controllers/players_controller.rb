class PlayersController < ApplicationController
  def create
    player = Player.create!(player_params)

    render json: PlayerSerializer.new(player).as_json, status: :created
  end

  def delete
    player = Player.find(params[:id])
    player.destroy

    render json: { message: "Player deleted successfully" }, status: :ok
  end

  private

  def player_params
    params.permit(:name)
  end
end
