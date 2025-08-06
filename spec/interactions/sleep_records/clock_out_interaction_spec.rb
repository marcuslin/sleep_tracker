RSpec.describe SleepRecords::ClockOutInteraction do
  let(:user) { create(:user) }
  let(:interaction) { described_class.run(user: user) }

  context "when user has sleeping record" do
    let!(:sleep_record) { create(:sleep_record, user: user, status: :sleeping) }

    it "updates sleep_record with correct clock out time" do
      expect(interaction.result.clock_out_time).to be_within(1.second).of(Time.current)
    end

    it "updates sleep_record with correct duration" do
      sleep_record.update!(clock_in_time: 8.hours.ago)

      expected_duration = 8
      expect(interaction.result.duration).to be_within(0.01).of(expected_duration)
    end

    it "updates sleep_record status to awake" do
      expect(interaction.result.status).to eq "awake"
    end
  end

  context "when user has no sleeping record" do
    it "returns error message" do
      expect(interaction.errors.full_messages).to include(I18n.t("interactions.sleep_records.clock_out.no_sleeping_record"))
    end
  end

  context "interaction result validation" do
    context "successful interaction" do
      let!(:sleep_record) { create(:sleep_record, user: user, status: :sleeping) }

      it "returns valid result" do
        expect(interaction.valid?).to be true
      end

      it "result contains the updated sleep_record" do
        expect(interaction.result).to eq sleep_record
      end
    end

    context "failed interaction" do
      it "returns invalid result" do
        expect(interaction.valid?).to be false
      end

      it "contains error messages" do
        expect(interaction.errors.full_messages).to include(I18n.t("interactions.sleep_records.clock_out.no_sleeping_record"))
      end
    end
  end
end
