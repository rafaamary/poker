class GameAction < ApplicationRecord
  belongs_to :player
  belongs_to :game_phase

  PERMITTED_ACTIONS = %w[check call raise fold showdown].freeze

  TURNS = {
    'pré-flop' => 1,
    'flop' => 2,
    'turn' => 3,
    'river' => 4
  }.freeze

  validates :action, presence: true, inclusion: { in: PERMITTED_ACTIONS }
  validates :amount, numericality: { greater_than_or_equal_to: 0 }
  validates :player, presence: true
  validates :game_phase, presence: true

  scope :check, -> { where(action: 'check') }
  scope :call, -> { where(action: 'call') }
  scope :raise, -> { where(action: 'raise') }
  scope :fold, -> { where(action: 'fold') }
  scope :showdown, -> { where(action: 'showdown') }
  scope :check_or_fold, -> { where(action: %w[check fold]) }
  scope :call_or_raise, -> { where(action: %w[call raise]) }

  def current_turn
    TURNS[game_phase.phase]
  end
end
