class Deck
  CARD_VALUES = %w[2 3 4 5 6 7 8 9 10 J Q K A].freeze
  CARD_SUITS = %w[S H D C].freeze

  def initialize
    @cards = build_deck.shuffle
  end

  def draw(n = 1)
    raise "Not enough cards" if n > @cards.size

    @cards.pop(n)
  end

  private

  def build_deck
    CARD_VALUES.product(CARD_SUITS).map { |value, suit| "#{value}#{suit}" }
  end
end
