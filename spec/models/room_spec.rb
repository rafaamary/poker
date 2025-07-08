RSpec.describe Room, type: :model do
  describe "validations" do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:max_players) }
    it { is_expected.to validate_numericality_of(:max_players).only_integer.is_greater_than(0) }
  end

  describe "#player_join" do
    let(:room) { Room.create!(name: "Test Room", max_players: 4) }
    let(:player) { Player.create!(name: "Test Player") }

    subject { room.player_join(player) }

    context "when the player is not already in the room" do
      it "adds the player to the room" do
        expect(subject).to be_truthy
        expect(room.current_players).to include(player.id)
      end
    end

    context "when the player is already in the room" do
      before { room.player_join(player) }

      it "does not add the player again" do
        expect(room.player_join(player)).to be_falsey
        expect(room.current_players.count { |p| p == player.id }).to eq(1)
      end
    end
  end

  describe "#player_leave" do
    let(:room) { Room.create!(name: "Test Room", max_players: 4) }
    let(:player) { Player.create!(name: "Test Player") }

    before { room.player_join(player) }

    subject { room.player_leave(player) }

    context "when the player is in the room" do
      it "removes the player from the room" do
        expect(subject).to be_truthy
        expect(room.current_players).not_to include(player.id)
      end
    end

    context "when the player is not in the room" do
      let(:another_player) { Player.create!(name: "Another Player") }

      it "does not remove any player" do
        expect(room.player_leave(another_player)).to be_falsey
        expect(room.current_players).to include(player.id)
      end
    end
  end

  describe "#current_game" do
    let(:room) { Room.create!(name: "Test Room", max_players: 4) }
    let(:game) { room.games.create! }
    let!(:another_game) { room.games.create!(finished_at: Time.current) }

    it "returns the current game" do
      game
      expect(room.current_game).to eq(game)
    end

    it "returns nil" do
      expect(room.current_game).to be_nil
    end
  end

  describe "#players" do
    let(:room) { Room.create!(name: "Test Room", max_players: 4) }
    let(:player1) { Player.create!(name: "Player 1") }
    let(:player2) { Player.create!(name: "Player 2") }

    before do
      room.player_join(player1)
      room.player_join(player2)
    end

    it "returns the players in the room" do
      expect(room.players).to contain_exactly(player1, player2)
    end

    it "does not include players not in the room" do
      another_player = Player.create!(name: "Another Player")
      expect(room.players).not_to include(another_player)
    end
  end

  describe "#can_proceed_to_next_phase?" do
    let(:room) { Room.create!(name: "Test Room", max_players: 4) }
    let(:game) { room.games.create! }

    before do
      allow(room).to receive(:current_game).and_return(game)
    end

    context "when the last game phase is not 'river'" do
      before do
        allow(game).to receive_message_chain(:game_phases, :last, :phase).and_return("turn")
      end

      it "returns true" do
        expect(room.can_proceed_to_next_phase?).to be_truthy
      end
    end

    context "when the last game phase is 'river'" do
      before do
        allow(game).to receive_message_chain(:game_phases, :last, :phase).and_return("river")
      end

      it "returns false" do
        expect(room.can_proceed_to_next_phase?).to be_falsey
      end
    end

    context "when there is no current game" do
      before do
        allow(room).to receive(:current_game).and_return(nil)
      end

      it "returns false" do
        expect(room.can_proceed_to_next_phase?).to be_falsey
      end
    end
  end
end
