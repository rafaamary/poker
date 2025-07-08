class PlayersController < ApplicationController
  def create
    player = Player.create!(player_params)

    render json: PlayerSerializer.new(player).as_json, status: :created
  rescue ActiveRecord::RecordInvalid => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  def delete
    player = Player.find(params[:id])
    player.destroy!

    render json: { message: "Player deleted successfully" }, status: :ok
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Player not found" }, status: :not_found
  end

  private

  def player_params
    params.permit(:name)
  end
end
