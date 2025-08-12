RSpec.describe Api::V1::FollowsController, type: :controller do
  let(:user) { create(:user) }
  let(:followee) { create(:user) }
  let(:token) { Auth::JwtService.encode(user_id: user.id) }
  let(:valid_headers) { { 'Authorization' => "Bearer #{token}" } }

  describe 'POST #follow_users' do
    before { request.headers.merge!(valid_headers) }

    context 'when following a valid user' do
      it 'returns success response with follow data' do
        post :follow_users, params: { followee_id: followee.id }

        expect(response).to have_http_status(:created)
        expect(json_response['success']).to be true
        expect(json_response['data']['follow']).to be_present
        expect(json_response['data']['follow']['followee_id']).to eq(followee.id)
        expect(json_response['data']['follow']['follower_id']).to eq(user.id)
      end
    end

    context 'when user not found' do
      it 'returns unprocessable_entity with error' do
        post :follow_users, params: { followee_id: 99999 }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response['success']).to be false
        expect(json_response['error']['message']).to include('Followee not found')
      end
    end

    context 'when trying to follow yourself' do
      it 'returns error response' do
        post :follow_users, params: { followee_id: user.id }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response['success']).to be false
        expect(json_response['error']['message']).to include('cannot follow yourself')
      end
    end

    context 'when already following user' do
      before { user.follows.create!(followee: followee) }

      it 'returns error response' do
        post :follow_users, params: { followee_id: followee.id }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response['success']).to be false
        expect(json_response['error']['message']).to include('already following')
      end
    end
  end
end
