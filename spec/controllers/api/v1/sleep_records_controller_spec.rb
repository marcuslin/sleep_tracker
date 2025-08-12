RSpec.describe Api::V1::SleepRecordsController, type: :controller do
  let(:user) { create(:user) }
  let(:token) { Auth::JwtService.encode(user_id: user.id) }
  let(:valid_headers) { { 'Authorization' => "Bearer #{token}" } }

  describe 'GET #index' do
    before { request.headers.merge!(valid_headers) }

    context 'when user has no sleep records' do
      it 'returns empty data array' do
        get :index

        expect(response).to have_http_status(:ok)
        expect(json_response['success']).to be true
        expect(json_response['data']).to eq([])
        expect(json_response['meta']['next_cursor']).to be_nil
      end
    end

    context 'when user has sleep records' do
      let!(:records) { create_list(:sleep_record, 5, user: user, status: :awake) }

      it 'returns sleep records in descending order' do
        get :index

        expect(response).to have_http_status(:ok)
        expect(json_response['success']).to be true
        expect(json_response['data'].size).to eq(5)
        expect(json_response['meta']['next_cursor']).to be_nil
      end

      context 'with pagination' do
        let!(:records) { create_list(:sleep_record, 25, user: user, status: :awake) }

        it 'respects limit parameter and shows next_cursor when more pages exist' do
          get :index, params: { limit: 10 }

          expect(json_response['data'].size).to eq(10)
          expect(json_response['meta']['next_cursor']).to be_present
        end
      end
    end
  end

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

  describe 'GET #friends_weekly' do
    before { request.headers.merge!(valid_headers) }

    let(:friend1) { create(:user) }
    let(:friend2) { create(:user) }
    let(:non_friend) { create(:user) }

    before do
      # Follow some users
      user.follows.create!(followee: friend1)
      user.follows.create!(followee: friend2)
    end

    context 'when friends have sleep records from last week' do
      before do
        # Create records in last week range
        last_week = Date.current.beginning_of_week.prev_week

        create(:sleep_record, user: friend1, duration: 8.5, created_at: last_week + 1.day, status: :awake)
        create(:sleep_record, user: friend2, duration: 7.2, created_at: last_week + 2.days, status: :awake)
        create(:sleep_record, user: non_friend, duration: 9.0, created_at: last_week + 1.day, status: :awake)
      end

      it 'returns friends sleep records sorted by duration desc' do
        get :friends_weekly

        expect(response).to have_http_status(:ok)
        expect(json_response['success']).to be true
        expect(json_response['data'].size).to eq(2)

        # Check sorting (longest first)
        durations = json_response['data'].map { |r| r['duration'] }
        expect(durations).to eq([ 8.5, 7.2 ])
      end

      it 'excludes non-friends records' do
        get :friends_weekly

        user_ids = json_response['data'].map { |r| r['user_id'] }
        expect(user_ids).not_to include(non_friend.id)
      end
    end

    context 'when no friends or no records' do
      it 'returns empty array' do
        get :friends_weekly

        expect(response).to have_http_status(:ok)
        expect(json_response['success']).to be true
        expect(json_response['data']).to eq([])
      end
    end
  end
end
