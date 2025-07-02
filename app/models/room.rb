class Room < ApplicationRecord
  has_many :games, dependent: :destroy

  validates :name, presence: true
  validates :max_players, presence: true, numericality: { only_integer: true, greater_than: 0 }

  def player_join(player)
    return false if current_players.any? { |p| p["id"] == player.id }

    self.current_players << PlayerSerializer.new(player).as_json
    save
  end

  def player_leave(player)
    return false unless current_players.any? { |p| p["id"] == player.id }

    self.current_players = current_players.reject { |p| p["id"] == player.id }
    save
  end

  def current_game
    games.find_by(finished_at: nil)
  end

  def players
    current_players.map { |p| Player.find(p["id"]) }
  end

  def can_proceed_to_next_phase?
    current_game.present? && current_game.game_phases.last.phase != 'river'
  end
end
