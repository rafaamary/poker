class GameChannel < ApplicationCable::Channel
  include WebSocketBroadcaster

  def subscribed
    if params[:player_id].present?
      begin
        player = Player.find(params[:player_id])
        @authenticated_player = player
        Rails.logger.info "Jogador #{player.name} (ID: #{player.id}) autenticado automaticamente no canal"

        transmit_success("Authenticated as #{player.name}")
      rescue ActiveRecord::RecordNotFound
        Rails.logger.error "Player #{params[:player_id]} não encontrado para autenticação automática"
        transmit_error("Player not found")
        return
      end
    end

    if params[:room_id].present?
      stream_from "game_room_#{params[:room_id]}"
      Rails.logger.info "Streaming da sala #{params[:room_id]} iniciado"
    end
  end

  def unsubscribed
    stop_all_streams
  end

  def current_player(data)
    current_game = Game.find_by(id: data["game_id"])
    return transmit_error("Game not found") unless current_game

    current_player = current_game.initial_state["current_player"]
    if current_player
      player = Player.find(current_player)
      transmit({
        type: "current_player",
        player_id: player.id,
        player_name: player.name,
        timestamp: Time.current.iso8601
      })
    else
      transmit_error("No current player found")
    end
  end

  def join_room(data)
    room_id = data["room_id"]
    return transmit_error("Room ID required") unless room_id

    begin
      room = Room.find(room_id)

      unless room.players.any? { |p| p == authenticated_player }
        success = room.player_join(authenticated_player)
        return transmit_error("Cannot join room") unless success
      end

      stream_from "game_room_#{room_id}"

      broadcast_player_joined(room_id, authenticated_player, room)

      transmit_room_state(room)

    rescue ActiveRecord::RecordNotFound
      transmit_error("Room not found")
    rescue => e
      transmit_error(e.message)
    end
  end

  def leave_room(data)
    return transmit_error("Authentication required") unless authenticated?

    room_id = data["room_id"]
    return transmit_error("Room ID required") unless room_id

    begin
      room = Room.find(room_id)
      success = room.player_leave(authenticated_player)

      if success
        stop_stream_from "game_room_#{room_id}"

        broadcast_player_left(room_id, authenticated_player, room)
      end

    rescue ActiveRecord::RecordNotFound
      transmit_error("Room not found")
    rescue => e
      transmit_error(e.message)
    end
  end

  def start_game(data)
    unless authenticated?
      return transmit_error("Authentication required")
    end

    room_id = data["room_id"]
    unless room_id
      return transmit_error("Room ID required")
    end

    begin
      room = Room.find(room_id)

      unless room.players.any? { |p| p == authenticated_player }
        return transmit_error("You are not in this room")
      end

      if room.current_game.present?
        return transmit_error("Game already in progress")
      end

      game = room.games.create!

      broadcast_game_started(room_id, game, room)
    rescue ActiveRecord::RecordNotFound => e
      transmit_error("Room not found")
    rescue => e
      transmit_error("Error starting game: #{e.message}")
    end
  end

  def player_action(data)
    return transmit_error("Authentication required") unless authenticated?

    room_id = data["room_id"]
    action = data["action_type"]
    amount = data["amount"]
    player_id = data["player_id"]
    player = Player.find_by(id: player_id) || authenticated_player

    return transmit_error("Room ID and action required") unless room_id && action

    begin
      room = Room.find(room_id)
      game = room.current_game

      return transmit_error("No active game") unless game

      game_phase = game.current_phase
      return transmit_error("No active game phase") unless game_phase

      unless is_player_turn?(game, authenticated_player)
        return transmit_error("Not your turn")
      end

      service = PlayerGameActionService.new(room, player, action, amount)
      result = service.perform

      check_and_advance_phase(game, room_id)
    rescue ActiveRecord::RecordNotFound
      transmit_error("Room or game not found")
    rescue ActiveRecord::RecordInvalid => e
      transmit_error(e.message)
    rescue => e
      transmit_error(e.message)
    end
  end

  def get_game_state(data)
    return transmit_error("Authentication required") unless authenticated?

    room_id = data["room_id"]
    return transmit_error("Room ID required") unless room_id

    begin
      room = Room.find(room_id)
      game = room.current_game

      return transmit_error("No active game") unless game

      game_state = {
        current_player: game.initial_state["current_player"],
        pot: game.pot,
        phase: game.current_phase&.phase || "pre-flop",
        players: room.players.map do |p|
          player_data = game.initial_state["players"]&.find { |pd| pd["id"] == p.id }
          {
            id: p.id,
            name: p.name,
            chips: p.chips,
            cards: player_data&.dig("cards") || []
          }
        end,
        community_cards: game.current_phase&.community_cards || []
      }

      transmit({
        type: "game_state_response",
        data: game_state
      })

    rescue ActiveRecord::RecordNotFound
      transmit_error("Room or game not found")
    rescue => e
      transmit_error(e.message)
    end
  end

  def authenticate(data)
    player_id = data["player_id"]
    unless player_id
      return transmit_error("Player ID required")
    end

    begin
      player = Player.find(player_id)
      @authenticated_player = player
      transmit_success("Authenticated as #{player.name}")
      Rails.logger.info "🔐 Autenticação manual do jogador #{player.name} (ID: #{player.id})"
    rescue ActiveRecord::RecordNotFound
      transmit_error("Player not found")
    end
  end

  private

  def authenticated_player
    @authenticated_player
  end

  def authenticated?
    authenticated_player.present?
  end

  def transmit_error(message)
    transmit({
      type: "error",
      message: message,
      timestamp: Time.current.iso8601
    })
  end

  def transmit_success(message)
    transmit({
      type: "success",
      message: message,
      timestamp: Time.current.iso8601
    })
  end

  def transmit_room_state(room)
    game = room.current_game

    transmit({
      type: "room_state",
      timestamp: Time.current.iso8601,
      data: {
        room: RoomSerializer.new(room).as_json,
        game: game&.as_json,
        current_phase: game&.current_phase&.as_json,
        players: room.players.map { |p| PlayerSerializer.new(p).as_json }
      }
    })
  end

  def broadcast_player_joined(room_id, player, room)
    ActionCable.server.broadcast("game_room_#{room_id}", {
      type: "player_joined",
      timestamp: Time.current.iso8601,
      data: {
        player: PlayerSerializer.new(player).as_json,
        room: RoomSerializer.new(room.reload).as_json
      }
    })
  end

  def broadcast_player_left(room_id, player, room)
    ActionCable.server.broadcast("game_room_#{room_id}", {
      type: "player_left",
      timestamp: Time.current.iso8601,
      data: {
        player: PlayerSerializer.new(player).as_json,
        room: RoomSerializer.new(room.reload).as_json
      }
    })
  end

  def broadcast_game_started(room_id, game, room)
    ActionCable.server.broadcast("game_room_#{room_id}", {
      type: "game_started",
      timestamp: Time.current.iso8601,
      data: {
        game: game.as_json,
        current_phase: game.current_phase.as_json,
        room: RoomSerializer.new(room.reload).as_json
      }
    })
  end

  def broadcast_phase_change(room_id, game, new_phase)
    ActionCable.server.broadcast("game_room_#{room_id}", {
      type: "phase_changed",
      timestamp: Time.current.iso8601,
      data: {
        phase: new_phase.phase,
        community_cards: new_phase.community_cards,
        game_state: {
          current_player: game.initial_state["current_player"],
          pot: game.pot
        }
      }
    })
  end

  def broadcast_turn_change(room_id, game, next_player)
    ActionCable.server.broadcast("game_room_#{room_id}", {
      type: "turn_changed",
      timestamp: Time.current.iso8601,
      data: {
        current_player: next_player.id,
        current_player_name: next_player.name,
        game_state: {
          phase: game.current_phase.phase,
          pot: game.pot
        }
      }
    })
  end

  def is_player_turn?(game, player)
    game.initial_state["current_player"] == player.id
  end

  def check_and_advance_phase(game, room_id)
    if defined?(NextPhaseService)
      next_phase_result = NextPhaseService.new(room_id).perform

      if next_phase_result[:phase_changed]
        broadcast_phase_change(room_id, game.reload, game.current_phase)
      end

      if next_phase_result[:turn_changed]
        next_player = Player.find(game.initial_state["current_player"])
        broadcast_turn_change(room_id, game, next_player)
      end
    end
  end
end
