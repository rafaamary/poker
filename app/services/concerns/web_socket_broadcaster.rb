module WebSocketBroadcaster
  extend self

  def broadcast_player_action(room_id, game_action, game)
    ActionCable.server.broadcast("game_room_#{room_id}", {
      type: "player_action",
      timestamp: Time.current.iso8601,
      data: {
        player: {
          id: game_action.player.id,
          name: game_action.player.name,
          chips: game_action.player.chips
        },
        action: {
          action_type: game_action.action,
          amount: game_action.amount,
          phase: game_action.game_phase.phase
        },
        game_state: {
          pot: game.pot,
          phase: game.current_phase.phase,
          community_cards: game.current_phase.community_cards,
          current_player: game.initial_state["current_player"]
        }
      }
    })
  end

  def broadcast_phase_change(room_id, new_phase, community_cards, game)
    ActionCable.server.broadcast("game_room_#{room_id}", {
      type: "phase_change",
      timestamp: Time.current.iso8601,
      data: {
        new_phase: new_phase,
        community_cards: community_cards,
        game_state: {
          pot: game.pot,
          phase: new_phase
        }
      }
    })
  end

  def broadcast_turn_change(room_id, current_player)
    ActionCable.server.broadcast("game_room_#{room_id}", {
      type: "turn_change",
      timestamp: Time.current.iso8601,
      data: {
        current_player: {
          id: current_player.id,
          name: current_player.name,
          chips: current_player.chips
        }
      }
    })
  end

  def broadcast_game_end(room_id, winner, pot, community_cards)
    ActionCable.server.broadcast("game_room_#{room_id}", {
      type: "game_ended",
      timestamp: Time.current.iso8601,
      data: {
        winner: winner,
        pot: pot,
        final_community_cards: community_cards
      }
    })
  end

  def broadcast_room_state(room_id, room, update_type = "room_update")
    game = room.current_game

    ActionCable.server.broadcast("game_room_#{room_id}", {
      type: update_type,
      timestamp: Time.current.iso8601,
      data: {
        room: {
          id: room.id,
          name: room.name,
          max_players: room.max_players,
          current_players_count: room.players.count
        },
        game_state: game ? {
          id: game.id,
          pot: game.pot,
          phase: game.current_phase&.phase,
          community_cards: game.current_phase&.community_cards || [],
          started_at: game.started_at,
          finished_at: game.finished_at
        } : nil,
        players: room.players.map do |player|
          {
            id: player.id,
            name: player.name,
            chips: player.chips
          }
        end
      }
    })
  end

  def broadcast_game_started(room_id, game, room)
    ActionCable.server.broadcast("game_room_#{room_id}", {
      type: "game_started",
      timestamp: Time.current.iso8601,
      data: {
        game: {
          id: game.id,
          pot: game.pot,
          started_at: game.started_at
        },
        current_phase: {
          phase: game.current_phase&.phase || "pre-flop",
          community_cards: game.current_phase&.community_cards || []
        },
        room: {
          id: room.id,
          name: room.name,
          max_players: room.max_players,
          current_players: room.current_players
        },
        initial_state: game.initial_state,
        players: room.players.map do |p|
          player_data = game.initial_state["players"]&.find { |pd| pd["id"] == p.id }
          {
            id: p.id,
            name: p.name,
            chips: p.chips,
            cards: player_data&.dig("cards") || []
          }
        end
      }
    })
  end
end
