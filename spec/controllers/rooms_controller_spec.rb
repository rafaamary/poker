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
end
