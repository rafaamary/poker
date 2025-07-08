RSpec.describe GamePhase, type: :model do
  let(:room) { Room.create!(name: "Test Room", max_players: 4) }
  let(:game) { Game.create!(room: room) }
  let(:game_phase) { GamePhase.create!(game: game, phase: "pre-flop") }
  let(:player) { Player.create!(name: "Test Player", chips: 100) }

  describe "validations" do
    it { is_expected.to validate_presence_of(:phase) }
    it { is_expected.to validate_inclusion_of(:phase).in_array(GamePhase::PHASES) }
  end

  describe "associations" do
    it { is_expected.to belong_to(:game) }
    it { is_expected.to have_many(:game_actions).dependent(:destroy) }
  end

  describe "#next_phase!" do
    it do
      expect {
        game_phase.next_phase!
      }.to change { game.game_phases.count }.by(2)

      new_phase = GamePhase.last
      expect(new_phase.phase).to eq("flop")
    end

    it "does not create a new phase if already at the last phase" do
      game_phase.update(phase: "river")
      expect {
        game_phase.next_phase!
      }.not_to change { GamePhase.count }
    end
  end

  describe "#can_check?" do
    it "returns true if there are no actions" do
      expect(game_phase.can_check?).to be true
    end

    it "returns false if there are actions" do
      game_phase.game_actions.create!(action: "raise", amount: 0, player: player)
      expect(game_phase.can_check?).to be false
    end
  end

  describe "#can_call?" do
    it "returns true if there are actions" do
      game_phase.game_actions.create!(action: "raise", amount: 10, player: player)
      expect(game_phase.can_call?).to be true
    end

    it "returns false if there are no actions" do
      expect(game_phase.can_call?).to be false
    end
  end

  describe "#biggest_bet" do
    it "returns the maximum bet amount from actions" do
      game_phase.game_actions.create!(action: "raise", amount: 10, player: player)
      game_phase.game_actions.create!(action: "raise", amount: 20, player: player)
      expect(game_phase.biggest_bet).to eq(20)
    end

    it "returns 0 if there are no actions" do
      expect(game_phase.biggest_bet).to eq(0)
    end
  end
end
