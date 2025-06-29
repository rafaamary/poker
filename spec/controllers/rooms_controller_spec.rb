RSpec.describe RoomsController, type: :controller do
  describe '#create' do
    let(:room) { Room.last }

    subject { post :create, params: { name: 'First Room', max_players: 3 } }

    it 'creates a new room' do
      expect {
        subject
      }.to change(Room, :count).by(1)
    end

    it 'returns the created room as JSON' do
      subject

      expect(response).to have_http_status(:created)
      expect(JSON.parse(response.body)).to eq({
        'id' => room.id,
        'name' => 'First Room',
        'max_players' => 3,
        'current_players' => []
      })
    end
  end

  describe '#index' do
    let!(:room1) { Room.create!(name: 'First Room', max_players: 4) }
    let!(:room2) { Room.create!(name: 'Second Room', max_players: 6) }

    subject { get :index }

    it 'returns all rooms as JSON' do
      subject

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to eq([
        {
          'id' => room1.id,
          'name' => 'First Room',
          'max_players' => 4,
          'current_players' => []
        },
        {
          'id' => room2.id,
          'name' => 'Second Room',
          'max_players' => 6,
          'current_players' => []
        }
      ])
    end
  end

  describe '#join' do
    let!(:room) { Room.create!(name: 'Joinable Room', max_players: 3) }
    let!(:player) { Player.create!(name: 'Test Player') }

    subject { post :join, params: { id: room.id, player_id: player.id } }

    context 'when the player joins successfully' do
      it 'adds the player to the room' do
        expect {
          subject
        }.to change { room.reload.current_players.count }.by(1)

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)).to eq({ 'message' => 'Player joined successfully' })
      end
    end

    context 'when the player is already in the room' do
      before do
        room.player_join(player)
      end

      it 'does not add the player again' do
        expect {
          subject
        }.not_to change { room.reload.current_players.count }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)).to eq({ 'error' => 'Player already in the room or could not be added' })
      end
    end
  end

  describe '#leave' do
    let!(:room) { Room.create!(name: 'Leaveable Room', max_players: 3) }
    let!(:player) { Player.create!(name: 'Test Player') }

    before do
      room.player_join(player)
    end

    subject { post :leave, params: { id: room.id, player_id: player.id } }

    context 'when the player leaves successfully' do
      it 'removes the player from the room' do
        expect {
          subject
        }.to change { room.reload.current_players.count }.by(-1)

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)).to eq({ 'message' => 'Player left successfully' })
      end
    end

    context 'when the player is not in the room' do
      before do
        room.player_leave(player)
      end

      it 'does not remove the player again' do
        expect {
          subject
        }.not_to change { room.reload.current_players.count }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)).to eq({ 'error' => 'Player not in the room or could not be removed' })
      end
    end
  end

  describe '#start' do
    let!(:room) { Room.create!(name: 'Startable Room', max_players: 4) }
    let!(:player1) { Player.create!(name: 'Player 1') }
    let!(:player2) { Player.create!(name: 'Player 2') }
    let(:json_response) { JSON.parse(response.body) }
    let(:cards_player1) { json_response['initial_state']['players'][0]['cards'] }
    let(:cards_player2) { json_response['initial_state']['players'][1]['cards'] }

    before do
      room.player_join(player1)
      room.player_join(player2)
    end

    subject { post :start, params: { id: room.id } }

    it 'starts a new game in the room' do
      expect {
        subject
      }.to change(Game, :count).by(1)

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to eq({
        'message' => 'Game started',
        'initial_state' => {
          'players' => [
            { 'id' => player1.id, 'chips' => player1.chips, 'cards' => cards_player1 },
            { 'id' => player2.id, 'chips' => player2.chips, 'cards' => cards_player2 }
          ],
          'community_cards' => [],
          'pot' => 0
        }
      })
    end
  end
end
