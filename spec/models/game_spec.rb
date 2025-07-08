RSpec.describe Game, type: :model do
  describe "validations" do
    it { is_expected.to belong_to(:room) }
    it { is_expected.to have_many(:game_phases).dependent(:destroy) }
  end

  describe "associations" do
    it { is_expected.to belong_to(:room) }
    it { is_expected.to have_many(:game_phases).dependent(:destroy) }
  end

  describe "#next_player!" do
    let(:room) { Room.create!(name: "Test Room", max_players: 4) }
    let(:game) { room.games.create! }
    let(:player1) { Player.create!(name: "Player 1", chips: 100) }
    let(:player2) { Player.create!(name: "Player 2", chips: 100) }

    before do
      room.player_join(player2)
      room.player_join(player1)
      game.initial_state = {
        players: [
          { id: player1.id, chips: player1.chips, cards: [] },
          { id: player2.id, chips: player2.chips, cards: [] }
        ],
        community_cards: [],
        current_player: player1.id
      }
      game.save!
    end

    it "updates the current player to the next player in order" do
      expect { game.next_player! }.to change { game.reload.initial_state["current_player"] }.from(player1.id).to(player2.id)
    end
  end
end
