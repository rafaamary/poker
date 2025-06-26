class RoomsController < ApplicationController
  def create
    room = Room.create!(room_params)

    render json: RoomSerializer.new(room).as_json, status: :created
  end

  def index
    rooms = Room.all

    render json: rooms, each_serializer: RoomSerializer
  end

  def join
    room = Room.find(params[:id])
    player = Player.find(params[:player_id])

    if room.player_join(player)
      render json: { message: "Player joined successfully" }, status: :ok
    else
      render json: { error: "Player already in the room or could not be added" }, status: :unprocessable_entity
    end
  end

  def leave
    room = Room.find(params[:id])
    player = Player.find(params[:player_id])

    if room.player_leave(player)
      render json: { message: "Player left successfully" }, status: :ok
    else
      render json: { error: "Player not in the room or could not be removed" }, status: :unprocessable_entity
    end
  end

  private

  def room_params
    params.permit(:name, :max_players)
  end
end
