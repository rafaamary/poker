class Room < ApplicationRecord
  has_many :games, dependent: :destroy

  validates :name, presence: true
  validates :max_players, presence: true, numericality: { only_integer: true, greater_than: 0 }

  def player_join(player)
    return false if current_players.include?(player.id)
    return false if current_players.size >= max_players

    self.current_players << player.id
    save!
  end

  def player_leave(player)
    return false unless current_players.include?(player.id)

    self.current_players -= [ player.id ]
    save!
  end

  def current_game
    games.find_by(finished_at: nil)
  end

  def players
    Player.where(id: current_players)
  end

  def can_proceed_to_next_phase?
    current_game&.game_phases&.last.phase != "river"
  end
end
