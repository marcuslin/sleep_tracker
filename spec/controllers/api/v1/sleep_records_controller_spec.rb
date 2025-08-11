require 'rails_helper'

RSpec.describe Api::V1::SleepRecordsController, type: :controller do
  let(:user) { create(:user) }
  let(:token) { Auth::JwtService.encode(user_id: user.id) }
  let(:valid_headers) { { 'Authorization' => "Bearer #{token}" } }

  describe 'POST #clock_in' do
    before { request.headers.merge!(valid_headers) }

    context 'when user has no active sleep record' do
      it 'creates a new sleep record' do
        expect {
          post :clock_in
        }.to change(SleepRecord, :count).by(1)
      end

      it 'returns created status' do
        post :clock_in

        expect(response).to have_http_status(:created)
      end

      it 'returns success response' do
        post :clock_in

        expect(json_response['success']).to be true
      end

      it 'includes the new record in response' do
        post :clock_in

        expect(json_response['data']['new_record']).to be_present
        expect(json_response['data']['new_record']['status']).to eq('sleeping')
      end

      it 'includes latest 50 sleep records in response' do
        create_list(:sleep_record, 60, user: user, status: :awake)
        post :clock_in

        expect(json_response['data']['sleep_records'].size).to eq(ENV.fetch("SLEEP_RECORDS_LIMIT", 50).to_i)
      end

      it 'sets the correct attributes on the new record' do
        post :clock_in

        new_record = SleepRecord.last
        expect(new_record.status).to eq('sleeping')
        expect(new_record.user).to eq(user)
        expect(new_record.clock_in_time).to be_present
      end
    end

    context 'when user already has an active sleep record' do
      before { create(:sleep_record, user: user, status: :sleeping) }

      it 'does not create a new sleep record' do
        expect {
          post :clock_in
        }.not_to change(SleepRecord, :count)
      end

      it 'returns unprocessable entity status' do
        post :clock_in

        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'returns error response' do
        post :clock_in

        expect(json_response['success']).to be false
      end

      it 'includes error message' do
        post :clock_in

        expect(json_response['error']['message']).to be_present
      end
    end
  end

  describe 'POST #clock_out' do
    before { request.headers.merge!(valid_headers) }

    context 'when user has no active sleep record' do
      it 'returns unprocessable entity status' do
        post :clock_out

        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'returns success false in response' do
        post :clock_out

        expect(json_response['success']).to be false
      end

      it 'includes error message' do
        post :clock_out

        expect(json_response['error']['message']).to be_present
        expect(json_response['error']['message']).to eq(I18n.t("interactions.sleep_records.clock_out.no_sleeping_record"))
      end
    end

    context 'when user has active sleep record' do
      let!(:sleep_record) { create(:sleep_record, user: user, status: :sleeping) }

      it 'returns success true' do
        post :clock_out

        expect(json_response['success']).to be true
      end

      it 'returns updated sleep record' do
        post :clock_out

        expect(response).to have_http_status(:ok)
        expect(json_response['data']['sleep_record']).to be_present
      end

      it 'sets clock_out_time and duration on the sleep record' do
        post :clock_out

        sleep_record.reload

        expect(sleep_record.clock_out_time).to be_present
        expect(sleep_record.duration).to be > 0
      end

      it 'updates sleep record status from sleeping to awake' do
        expect {
          post :clock_out
        }.to change { sleep_record.reload.status }.from('sleeping').to('awake')
      end
    end
  end
end
