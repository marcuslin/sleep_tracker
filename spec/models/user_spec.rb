require 'rails_helper'

RSpec.describe User, type: :model do
  let(:user_one) { create(:user) }
  let(:user_two) { create(:user) }

  describe 'associations' do
    it { should have_many(:sleep_records).dependent(:destroy) }
    it { should have_many(:follows).with_foreign_key(:follower_id) }
    it { should have_many(:followees).through(:follows) }
    it { should have_many(:followed_by).with_foreign_key(:followee_id) }
    it { should have_many(:followers).through(:followed_by) }
  end

  describe 'follow relationships' do
    before do
      create(:follow, follower: user_one, followee: user_two)
    end

    it 'can follow another user' do
      expect(user_one.followees).to include(user_two)
    end

    it 'can be followed by another user' do
      expect(user_two.followers).to include(user_one)
    end
  end
end
