RSpec.describe Room, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:max_players) }
    it { is_expected.to validate_numericality_of(:max_players).only_integer.is_greater_than(0) }
  end

  describe '#player_join' do
    let(:room) { Room.create!(name: 'Test Room', max_players: 4) }
    let(:player) { Player.create!(name: 'Test Player') }
    let(:player_serializer) { PlayerSerializer.new(player).as_json.with_indifferent_access }

    subject { room.player_join(player) }

    context 'when the player is not already in the room' do
      it 'adds the player to the room' do
        expect(subject).to be_truthy
        expect(room.current_players).to include(player_serializer)
      end
    end

    context 'when the player is already in the room' do
      before { room.player_join(player) }

      it 'does not add the player again' do
        expect(room.player_join(player)).to be_falsey
        expect(room.current_players.count { |p| p['id'] == player.id }).to eq(1)
      end
    end
  end
end
