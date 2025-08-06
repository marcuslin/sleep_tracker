RSpec.describe SleepRecords::ClockInInteraction do
  let(:user) { create(:user) }
  let(:interaction) { described_class.run(user: user) }

  context "User has no sleep record" do
    it "create new sleep record" do
      expect(interaction.valid?).to be true
      expect(interaction.result).to be_a(SleepRecord)
      expect(interaction.result.sleeping?).to be true
    end
  end

  context "User has existing sleep record" do
    before { create(:sleep_record, user: user, status: :sleeping) }

    it "fails with error message" do
      expect(interaction.valid?).to be false
      expect(interaction.errors.full_messages).to include(I18n.t("interactions.sleep_records.clock_in.already_sleeping"))
    end
  end
end
