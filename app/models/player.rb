class Player < ApplicationRecord
  validates :name, presence: true
  validates :chips, presence: true, numericality: { greater_than_or_equal_to: 0 }

  has_many :game_actions, dependent: :destroy

  def receive_pot(amount)
    valid_amount?(amount)

    increment!(:chips, amount)
  end

  private

  def valid_amount?(amount)
    if amount.negative?
      raise ActiveRecord::RecordInvalid.new(self), "Cannot receive negative chips"
    end
  end
end
