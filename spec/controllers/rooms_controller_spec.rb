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
end
