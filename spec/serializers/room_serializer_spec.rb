RSpec.describe RoomSerializer do
  let(:room) { Room.create!(name: "First Room", max_players: 3) }
  let(:expected_json) {
    {
      id: room.id,
      name: "First Room",
      max_players: 3,
      current_players: []
    }
  }

  subject { described_class.new(room) }

  it "serializes id, name, max_players and current_players" do
    expect(subject.serializable_hash).to eq(expected_json)
  end
end
