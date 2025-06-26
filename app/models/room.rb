class Room < ApplicationRecord
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
end
