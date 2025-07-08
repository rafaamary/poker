RSpec.describe Player, type: :model do
  describe "validations" do
    it { is_expected.to validate_presence_of(:name) }
  end

  describe "associations" do
    it { is_expected.to have_many(:game_actions).dependent(:destroy) }
  end

  describe "#receive_pot" do
    let(:player) { Player.create!(name: 'Teste', chips: 100) }

    it "increments the player's chips" do
      expect { player.receive_pot(50) }.to change { player.reload.chips }.by(50)
    end

    it "raises an error if the amount is negative" do
      expect { player.receive_pot(-50) }.to raise_error(ActiveRecord::RecordInvalid, "Cannot receive negative chips")
    end
  end
end
