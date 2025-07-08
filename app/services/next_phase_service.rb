class NextPhaseService
  def initialize(room_id)
    @room = Room.find(room_id)
  end

  def perform
    puts @room.can_proceed_to_next_phase?
    raise "Room is not in a valid state to proceed to the next phase" unless @room.can_proceed_to_next_phase?

    ActiveRecord::Base.transaction do
      puts 'AQUIIIIIIIIIIIIIIIIIIII'
      next_phase = @room.current_game.game_phases.last.next_phase!

      puts 'AQUIIIIIIIIIIIIIIIIIIII'
      puts next_phase.inspect

      {
        phase: next_phase.phase,
        community_cards: all_cards,
      }
    end
  rescue StandardError => e
    raise e
  end

  private

  def all_cards
    @room.current_game.game_phases.pluck(:community_cards).reject(&:empty?).flatten
  end
end