class Game < ApplicationRecord
  belongs_to :room
  has_many :game_phases, dependent: :destroy

  before_create :set_initial_state, :set_started_at
  after_create :create_initial_game_phase

  def next_player!
    initial_state["current_player"] = next_player_id
    save!
  end

  def current_phase
    game_phases.last
  end

  private

  def set_initial_state
    deck = Deck.new

    self.initial_state = {
      players: assign_players(deck),
      community_cards: deck.draw(5),
      current_player: determine_order[0]
    }
  end

  def assign_players(deck)
    room.players.map do |player|
      {
        id: player.id,
        chips: player.chips,
        cards: deck.draw(2)
      }
    end
  end

  def set_started_at
    self.started_at = Time.current
  end

  def create_initial_game_phase
    game_phases.create!(
      phase: "pre-flop",
      community_cards: []
    )
  end

  def determine_order
    room.current_players
  end

  def next_player_id
    current_index = determine_order.index { |p| p == current_player_id }
    next_index = (current_index + 1) % determine_order.size
    determine_order[next_index]
  end

  def current_player_id
    initial_state["current_player"]
  end
end
