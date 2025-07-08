RSpec.describe Deck do
  describe "constants" do
    it "has CARD_VALUES" do
      expect(Deck::CARD_VALUES).to eq(%w[2 3 4 5 6 7 8 9 10 J Q K A])
    end

    it "has CARD_SUITS" do
      expect(Deck::CARD_SUITS).to eq(%w[S H D C])
    end
  end

  describe '#initialize' do
    it 'creates a deck with 52 unique cards' do
      deck = Deck.new
      expect(deck.send(:build_deck).uniq.size).to eq(52)
    end
  end

  describe '#draw' do
    let(:deck) { Deck.new }

    it 'returns exactly cards' do
      cards = deck.draw(5)
      expect(cards.size).to eq(5)
    end

    it 'remove deck cards' do
      expect { deck.draw(5) }.to change { deck.instance_variable_get(:@cards).size }.by(-5)
    end

    it 'raises an error' do
      expect { deck.draw(53) }.to raise_error("Not enough cards")
    end
  end
end
