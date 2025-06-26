RSpec.describe PlayersController, type: :controller do
  describe '#create' do
    let(:player) { Player.last }

    subject { post :create, params: { name: 'John Doe' } }

    it 'creates a new player' do
      expect {
        subject
      }.to change(Player, :count).by(1)
    end

    it 'returns the created player as JSON' do
      subject

      expect(response).to have_http_status(:created)
      expect(JSON.parse(response.body)).to eq({
        'id' => player.id,
        'name' => player.name,
        'chips' => 1000
      })
    end
  end
end
