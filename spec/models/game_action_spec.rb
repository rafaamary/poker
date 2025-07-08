RSpec.describe GameAction, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:player) }
    it { is_expected.to belong_to(:game_phase) }
    it { is_expected.to have_one(:game).through(:game_phase) }
    it { is_expected.to have_one(:room).through(:game) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:action) }
    it { is_expected.to validate_inclusion_of(:action).in_array(GameAction::PERMITTED_ACTIONS) }
    it { is_expected.to validate_numericality_of(:amount).is_greater_than_or_equal_to(0) }
    it { is_expected.to validate_presence_of(:player) }
    it { is_expected.to validate_presence_of(:game_phase) }
  end

  describe "constants" do
    it "defines PERMITTED_ACTIONS" do
      expect(GameAction::PERMITTED_ACTIONS).to eq(%w[check call raise fold showdown])
    end

    it "defines TURNS" do
      expect(GameAction::TURNS).to eq({
        "pre-flop" => 1,
        "flop" => 2,
        "turn" => 3,
        "river" => 4
      })
    end
  end

  describe "scopes" do
    it "returns actions for check" do
      expect(GameAction.check.to_sql).to include(`"action\" = 'check'`)
    end

    it "returns actions for call" do
      expect(GameAction.call.to_sql).to include(`"action\" = 'call'`)
    end

    it "returns actions for raise" do
      expect(GameAction.raise.to_sql).to include(`"action\" = 'raise'`)
    end

    it "returns actions for fold" do
      expect(GameAction.fold.to_sql).to include(`"action\" = 'fold'`)
    end

    it "returns actions for check or fold" do
      expect(GameAction.check_or_fold.to_sql).to include(`"action\" IN ('check', 'fold')`)
    end

    it "returns actions for call or raise" do
      expect(GameAction.call_or_raise.to_sql).to include(`"action\" IN ('call', 'raise')`)
    end
  end

  describe "#current_turn" do
    let(:room) { Room.create!(name: "Test Room", max_players: 4) }
    let(:game) { Game.create!(room: room) }
    let(:game_phase) { GamePhase.create!(phase: "flop", game: game) }
    let(:game_action) { GameAction.new(game_phase: game_phase) }

    it "returns the current turn based on the game phase" do
      expect(game_action.current_turn).to eq(GameAction::TURNS["flop"])
    end

    it "returns nil if the phase is not recognized" do
      game_phase.update(phase: "unknown")
      expect(game_action.current_turn).to be_nil
    end
  end
end
