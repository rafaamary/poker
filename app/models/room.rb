class Room < ApplicationRecord
  validates :name, presence: true
  validates :max_players, presence: true, numericality: { only_integer: true, greater_than: 0 }
end
