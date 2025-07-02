class GamePhase < ApplicationRecord
  PHASES = %w[pré-flop flop turn river].freeze
  COUNT_CARDS = {
    'flop' => 3,
    'turn' => 1,
    'river' => 1,
  }

  belongs_to :game
  has_many :game_actions, dependent: :destroy

  validates :phase, presence: true, inclusion: { in: PHASES }

  def next_phase!
    next_phase = PHASES[PHASES.index(phase) + 1]

    return unless next_phase

    GamePhase.create!(
      game: Game.find(game.id),
      phase: next_phase,
      community_cards: cards(next_phase),
    )
  end

  def can_check?
    game_actions.call_or_raise.empty?
  end

  def can_call?
    game_actions.call_or_raise.present?
  end

  def biggest_bet
    game_actions.call_or_raise.maximum(:amount) || 0
  end

  def cards(phase)
    return if phase == 'pré-flop'

    full_deck.pop(COUNT_CARDS[phase])
  end

  def full_deck
    values = %w[2 3 4 5 6 7 8 9 10 J Q K A]
    suits  = %w[S H D C]

    deck = values.product(suits).map { |value, suit| "#{value}#{suit}" }
    deck.shuffle
  end
end
