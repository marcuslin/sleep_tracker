require 'rails_helper'

RSpec.describe SleepRecord, type: :model do
  let(:user_one) { create(:user) }

  describe 'associations' do
    it { should belong_to(:user) }
  end

  describe 'status' do
    it { should define_enum_for(:status).with_values(sleeping: 0, awake: 1) }

    context 'when newly created' do
      let(:sleep_record) { create(:sleep_record, user: user_one) }

      it 'defaults to sleeping status' do
        expect(sleep_record.sleeping?).to be true
      end
    end

    context 'when currently sleeping' do
      let(:sleep_record) { create(:sleep_record, user: user_one) }

      it 'can be awakened' do
        sleep_record.awake!
        expect(sleep_record.awake?).to be true
      end
    end
  end
end
