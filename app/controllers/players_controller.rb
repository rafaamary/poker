class PlayersController < ApplicationController
  def create
    puts "Creating player with params: #{params.inspect}"
    player = Player.create!(player_params)

    puts "Player created: #{player.inspect}"

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
