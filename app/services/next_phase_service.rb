class NextPhaseService
  def initialize(room_id)
    @room = Room.find(room_id)
  end

  def perform
    raise "Room is not in a valid state to proceed to the next phase" unless @room.can_proceed_to_next_phase?

    ActiveRecord::Base.transaction do
      next_phase = @room.current_game.game_phases.last.next_phase!

      {
        phase: next_phase.phase,
        community_cards: next_phase.community_cards,
      }
    end
  rescue StandardError => e
    raise e
  end
end