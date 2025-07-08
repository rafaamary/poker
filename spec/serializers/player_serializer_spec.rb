RSpec.describe PlayerSerializer do
  let(:player) { Player.create!(name: "John Doe") }
  let(:expected_json) {
    {
      id: player.id,
      name: player.name,
      chips: 1000
    }
  }

  subject { described_class.new(player) }

  it "serializes id, name and fixed chips" do
    expect(subject.serializable_hash).to eq(expected_json)
  end
end
