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

  def start
    room = Room.find(params[:id])
    game = Game.create!(room: room)

    render json: {
      message: 'Game started',
      initial_state: game.initial_state,
    }
  end

  def action
    room = Room.find(params[:id])
    player = Player.find(params[:player_id])

    game_action = PlayerGameActionService.new(room, player, params_action, params[:amount]).perform

    render json: {
      message: 'Action performed successfully',
      game_state: {
        current_turn: game_action['current_turn'],
        pot: game_action['pot'],
      }
    }
  rescue StandardError => e
    Rails.logger.error("Error performing action: #{e.message}")
    render json: { error: e.message }, status: :unprocessable_entity
  end

  def next_phase
    NextPhaseService.new(params[:id]).perform
  rescue StandardError => e
    Rails.logger.error("Error proceeding to next phase: #{e.message}")
    render json: { error: e.message }, status: :unprocessable_entity
  end

  def end
    room = Room.find(params[:id])
    end_game = EndGameService.new(room).perform

    render json: end_game, status: :ok
  rescue StandardError => e
    Rails.logger.error("Error ending game: #{e.message}")
    render json: { error: e.message }, status: :unprocessable_entity
  end

  private

  def room_params
    params.permit(:name, :max_players)
  end

  def params_action
    request.request_parameters[:action]
  end
end
