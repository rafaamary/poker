RSpec.describe EndGameService do
  let(:room) { Room.create!(name: "Test Room", max_players: 2) }
  let(:game) { Game.create!(room: room) }
  let(:player1) { Player.create!(name: "Player 1", chips: 1000) }
  let(:player2) { Player.create!(name: "Player 2", chips: 1000) }

  before do
    room.player_join(player1)
    room.player_join(player2)
    game

    game.update!(pot: 200)
  end

  describe '#perform' do
    it 'winner and distributes the pot' do
      service = EndGameService.new(room)
      allow(service).to receive(:determine_winner).and_return(player1)
      allow(service).to receive(:all_cards).and_return([])

      result = service.perform

      expect(result[:winner][:player_id]).to eq(player1.id)
      expect(player1.reload.chips).to eq(1200)
    end
  end
end
