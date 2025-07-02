class GamePhase < ApplicationRecord
  PHASES = %w[pré-flop flop turn river].freeze

  belongs_to :game
  has_many :game_actions, dependent: :destroy

  validates :phase, presence: true, inclusion: { in: PHASES }

  def next_phase!
    next_phase = PHASES[PHASES.index(phase) + 1]

    return unless next_phase

    GamePhase.create!(
      game: game,
      phase: next_phase,
      community_cards: cards,
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
end
