RSpec.describe Follows::DestroyInteraction do
  let(:user) { create(:user) }
  let(:followee) { create(:user) }

  describe '#execute' do
    context 'when user is following the followee' do
      before { user.follows.create!(followee: followee) }

      it 'destroys the follow relationship' do
        expect {
          described_class.run!(user: user, followee_id: followee.id)
        }.to change { user.follows.count }.by(-1)
      end

      it 'returns the destroyed follow' do
        result = described_class.run!(user: user, followee_id: followee.id)
        expect(result).to be_a(Follow)
        expect(result.destroyed?).to be true
      end
    end

    context 'when followee does not exist' do
      it 'adds validation error' do
        interaction = described_class.run(user: user, followee_id: 99999)
        expect(interaction).to be_invalid
        expect(interaction.errors.full_messages).to include('Unfollowee not found')
      end
    end

    context 'when not following the user' do
      it 'adds validation error' do
        interaction = described_class.run(user: user, followee_id: followee.id)
        expect(interaction).to be_invalid
        expect(interaction.errors.full_messages).to include('You are not following this user')
      end
    end
  end
end
