RSpec.describe Follows::CreateInteraction do
  let(:user) { create(:user) }
  let(:followee) { create(:user) }

  describe '#execute' do
    context 'with valid inputs' do
      it 'creates a follow relationship' do
        expect {
          described_class.run!(user: user, followee_id: followee.id)
        }.to change { user.follows.count }.by(1)
      end

      it 'returns the created follow' do
        result = described_class.run!(user: user, followee_id: followee.id)

        expect(result.followee_id).to eq(followee.id)
        expect(result.follower_id).to eq(user.id)
      end
    end

    context 'when followee does not exist' do
      it 'adds validation error' do
        interaction = described_class.run(user: user, followee_id: 99999)

        expect(interaction).to be_invalid
        expect(interaction.errors.full_messages).to include('Followee not found')
      end
    end

    context 'when trying to follow self' do
      it 'adds validation error' do
        interaction = described_class.run(user: user, followee_id: user.id)

        expect(interaction).to be_invalid
        expect(interaction.errors.full_messages).to include('You cannot follow yourself')
      end
    end

    context 'when already following' do
      before { user.follows.create!(followee: followee) }

      it 'adds validation error' do
        interaction = described_class.run(user: user, followee_id: followee.id)

        expect(interaction).to be_invalid
        expect(interaction.errors.full_messages).to include('You are already following this user')
      end
    end
  end
end
