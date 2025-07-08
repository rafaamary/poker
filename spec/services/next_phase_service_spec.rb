RSpec.describe NextPhaseService do
  let(:room) { Room.create!(name: "Test Room", max_players: 2) }
  let(:game) { Game.create!(room: room) }
  let(:player1) { Player.create!(name: "Player 1", chips: 1000) }
  let(:player2) { Player.create!(name: "Player 2", chips: 1000) }
  let(:game_phase) { GamePhase.create!(game: game, phase: "pre-flop", community_cards: []) }

  before do
    room.player_join(player1)
    room.player_join(player2)
    game
  end

  describe '#perform' do
    it 'proceeds to the next phase' do
      service = NextPhaseService.new(room.id)
      result = service.perform

      expect(result[:phase]).to eq("flop")
      expect(game.reload.current_phase.phase).to eq("flop")
    end

    context 'when error occurs' do
      let!(:game_phase) { GamePhase.create!(game: game, phase: "river") }

      it 'raises an error' do
        service = NextPhaseService.new(room.id)

        expect { service.perform }.to raise_error("Room is not in a valid state to proceed to the next phase")
      end
    end
  end
end
