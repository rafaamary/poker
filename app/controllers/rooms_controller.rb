class RoomsController < ApplicationController
    def create
    room = Room.create!(room_params)

    render json: RoomSerializer.new(room).as_json, status: :created
  end

  private

  def room_params
    params.permit(:name, :max_players)
  end
end
