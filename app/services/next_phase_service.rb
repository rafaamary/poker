class NextPhaseService
  def initialize(room_id)
    @room = Room.find(room_id)
  end

  def perform
    raise "Room is not in a valid state to proceed to the next phase" unless @room.can_proceed_to_next_phase?

    ActiveRecord::Base.transaction do
      next_phase = current_phase.next_phase!

      {
        phase: next_phase.phase,
        community_cards: all_cards
      }
    end
  rescue StandardError => e
    raise e
  end

  private

  def current_phase
    current_game.current_phase
  end

  def all_cards
    current_game.game_phases.pluck(:community_cards).reject(&:empty?).flatten
  end

  def current_game
    @room.current_game
  end
end
