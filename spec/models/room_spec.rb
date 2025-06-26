RSpec.describe Room, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:max_players) }
    it { is_expected.to validate_numericality_of(:max_players).only_integer.is_greater_than(0) }
  end
end
