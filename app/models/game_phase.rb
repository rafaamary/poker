class GamePhase < ApplicationRecord
  PHASES = %w[pré-flop flop turn river].freeze

  belongs_to :game

  validates :phase, presence: true, inclusion: { in: PHASES }
end
