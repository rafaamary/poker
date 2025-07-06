class Player < ApplicationRecord
  validates :name, presence: true

  has_many :game_actions, dependent: :destroy

  def can_play?(room)
    room.players.include?(self) ||
    self.game_actions.where(room: room).fold.exists?
  end

  def receive_pot(pot)
    self.update!(chips: self.chips + pot)
  end
end
