class GameChannel < ApplicationCable::Channel
  def subscribed
    # Allow subscription but require authentication for specific actions
    # Subscribe to the game stream based on player_id or room_id
    if params[:player_id]
      puts params
      stream_from "game_#{params[:player_id]}"
    elsif params[:room_id]
      stream_from "game_#{params[:room_id]}"
    else
      stream_from "game_"
    end
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
    stop_all_streams
  end

  def authenticate(data)
    player_id = data['player_id']
    return transmit(error: "Player ID required") unless player_id

    begin
      player = Player.find(player_id)
      # Store the authenticated player for this channel instance
      @authenticated_player = player
      transmit(success: "Authenticated as #{player.name}")
    rescue ActiveRecord::RecordNotFound
      transmit(error: "Player not found")
    end
  end

  def join_game(data)
    return transmit(error: "Authentication required") unless authenticated_player

    room_id = data['room_id']
    return unless room_id

    begin
      room = Room.find(room_id)
      
      # Add player to room using the existing method
      unless room.players.any? { |p| p.id == authenticated_player.id }
        success = room.player_join(authenticated_player)
        return transmit(error: "Cannot join room (full or already joined)") unless success
      end

      # Stream from the specific game room
      stream_from "game_#{room_id}"
      
      # Broadcast to all players in the room that someone joined
      ActionCable.server.broadcast("game_#{room_id}", {
        type: 'player_joined',
        player: PlayerSerializer.new(authenticated_player).as_json,
        room: RoomSerializer.new(room.reload).as_json
      })
      
    rescue ActiveRecord::RecordNotFound
      transmit(error: "Room not found")
    rescue => e
      transmit(error: e.message)
    end
  end

  def start_game(data)
    return transmit(error: "Authentication required") unless authenticated_player

    room_id = data['room_id']
    return unless room_id

    begin
      room = Room.find(room_id)
      
      # Check if player is in the room
      unless room.players.any? { |p| p.id == authenticated_player.id }
        transmit(error: "You are not in this room")
        return
      end

      # Check if there's already an active game
      if room.current_game.present?
        transmit(error: "Game already in progress")
        return
      end

      # Create a new game
      game = room.games.create!
      
      # Broadcast to all players in the room that the game started
      ActionCable.server.broadcast("game_#{room_id}", {
        type: 'game_started',
        game: game.as_json,
        room: RoomSerializer.new(room.reload).as_json
      })
      
    rescue ActiveRecord::RecordNotFound
      transmit(error: "Room not found")
    rescue => e
      transmit(error: e.message)
    end
  end

  def leave_game(data)
    return transmit(error: "Authentication required") unless authenticated_player

    room_id = data['room_id']
    return unless room_id

    begin
      room = Room.find(room_id)
      
      # Remove player from room using the existing method
      success = room.player_leave(authenticated_player)
      
      # Stop streaming from this room
      stop_stream_from "game_#{room_id}"
      
      # Broadcast to remaining players that someone left
      if success
        ActionCable.server.broadcast("game_#{room_id}", {
          type: 'player_left',
          player: PlayerSerializer.new(authenticated_player).as_json,
          room: RoomSerializer.new(room.reload).as_json
        })
      end
      
    rescue ActiveRecord::RecordNotFound
      transmit(error: "Room not found")
    rescue => e
      transmit(error: e.message)
    end
  end

  def game_action(data)
    return transmit(error: "Authentication required") unless authenticated_player

    room_id = data['room_id']
    action = data['action']
    amount = data['amount']
    
    return unless room_id && action

    begin
      room = Room.find(room_id)
      game = room.current_game
      
      return transmit(error: "No active game") unless game
      
      # Get the current game phase
      game_phase = game.game_phases.last
      return transmit(error: "No active game phase") unless game_phase

      # Create the game action
      game_action = GameAction.create!(
        player: authenticated_player,
        game_phase: game_phase,
        action: action,
        amount: amount || 0
      )

      # Process the action using the service if available
      PlayerGameActionService.new(game_action).call if defined?(PlayerGameActionService)
      
      # Broadcast the action to all players
      ActionCable.server.broadcast("game_action", {
        type: 'game_action',
        action: game_action.as_json,
        game: game.reload.as_json,
        room: RoomSerializer.new(room.reload).as_json
      })

      puts '¨¨¨¨¨¨¨¨¨¨¨¨'

      
    rescue ActiveRecord::RecordNotFound
      transmit(error: "Room or game not found")
    rescue ActiveRecord::RecordInvalid => e
      transmit(error: e.message)
    rescue => e
      transmit(error: e.message)
    end
  end

  private

  def authenticated_player
    @authenticated_player
  end
end
