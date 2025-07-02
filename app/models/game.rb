class Game < ApplicationRecord
  belongs_to :room
  has_many :game_phases, dependent: :destroy

  before_create :set_initial_state, :set_started_at
  after_create :create_initial_game_phase

  private

  def set_initial_state
    self.initial_state = {
      players: players,
      community_cards: [],
    }
  end

  def set_started_at
    self.started_at = Time.current
  end

  def players
    room.current_players.map do |player|
      player.slice('id', 'chips').merge(cards)
    end
  end

  def cards
    {
      cards: full_deck.pop(2)
    }.with_indifferent_access
  end

  def full_deck
    values = %w[2 3 4 5 6 7 8 9 10 J Q K A]
    suits  = %w[S H D C]

    deck = values.product(suits).map { |value, suit| "#{value}#{suit}" }
    deck.shuffle
  end

  def create_initial_game_phase
    GamePhase.create!(
      game: self,
      phase: 'pré-flop',
      community_cards: [],
    )
  end
end
