class GamePhase < ApplicationRecord
  PHASES = %w[pre-flop flop turn river].freeze
  COMMUNITY_CARD_INDEXES = {
    "flop" => [ 0, 1, 2 ],
    "turn" => [ 3 ],
    "river" => [ 4 ]
  }.freeze

  belongs_to :game
  has_many :game_actions, dependent: :destroy

  validates :phase, presence: true, inclusion: { in: PHASES }

  def next_phase!
    current_index = PHASES.index(phase)
    return if current_index.nil? || current_index >= PHASES.size - 1

    next_phase = PHASES[current_index + 1]

    initiate_player!

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

  private

  def cards(phase)
    return [] unless COMMUNITY_CARD_INDEXES.key?(phase)

    game.initial_state["community_cards"].values_at(*COMMUNITY_CARD_INDEXES[phase])
  end

  def initiate_player!
    current_player_id = room.current_players[0]

    game.update!(
      initial_state: game.initial_state.merge(
        "current_player" => current_player_id
      )
    )
  end

  def room
    game.room
  end
end
