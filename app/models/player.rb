class Player < ApplicationRecord
  validates :name, presence: true
  validates :chips, presence: true, numericality: { greater_than_or_equal_to: 0 }

  has_many :game_actions, dependent: :destroy

  def can_play?(room)
    player_in_room?(room) || player_folded?(room)
  end

  def receive_pot(amount)
    increment!(:chips, amount)
  end

  private

  def player_folded?(room)
    game_actions
      .joins(game_phase: { game: :room })
      .where(rooms: { id: room.id })
      .fold
      .exists?
  end

  def player_in_room?(room)
    room.players.include?(self)
  end
end
