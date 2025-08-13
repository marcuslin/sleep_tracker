require 'swagger_helper'

RSpec.describe 'api/v1/follows', type: :request do
  let(:user) { create(:user) }
  let(:followee) { create(:user) }
  let(:token) { Auth::JwtService.encode(user_id: user.id) }
  let(:Authorization) { "Bearer #{token}" }

  path '/api/v1/follows' do
    post('Follow user') do
      tags 'Follows'
      description 'Follow another user'
      consumes 'application/json'
      produces 'application/json'
      security [ Bearer: [] ]

      parameter name: :follow_params, in: :body, schema: {
        type: :object,
        properties: {
          followee_id: { type: :integer, description: 'ID of the user to follow' }
        },
        required: [ 'followee_id' ]
      }

      response(201, 'created') do
        schema type: :object,
               properties: {
                 success: { type: :boolean },
                 data: {
                   type: :object,
                   properties: {
                     follow: { '$ref' => '#/components/schemas/Follow' }
                   }
                 }
               }

        let(:follow_params) { { followee_id: followee.id } }

        run_test! do |response|
          expect(json_response['success']).to eq(true)
          expect(json_response['data']['follow']).to be_present
          expect(json_response['data']['follow']['followee_id']).to eq(followee.id)
        end
      end

      response(422, 'unprocessable_content') do
        schema '$ref' => '#/components/schemas/ErrorResponse'

        context 'when trying to follow self' do
          let(:follow_params) { { followee_id: user.id } }

          run_test! do |response|
            expect(json_response['success']).to eq(false)
            expect(json_response['error']['message']).to be_present
          end
        end
      end

      response(422, 'unprocessable_content') do
        schema '$ref' => '#/components/schemas/ErrorResponse'

        context 'when already following user' do
          let(:follow_params) { { followee_id: followee.id } }

          before { create(:follow, follower: user, followee: followee) }

          run_test! do |response|
            expect(json_response['success']).to eq(false)
            expect(json_response['error']['message']).to be_present
          end
        end
      end

      response(401, 'unauthorized') do
        schema '$ref' => '#/components/schemas/ErrorResponse'
        let(:Authorization) { 'Bearer invalid_token' }
        let(:follow_params) { { followee_id: followee.id } }
        run_test!
      end
    end
  end

  path '/api/v1/follows/{followee_id}' do
    parameter name: 'followee_id', in: :path, type: :integer, description: 'ID of the user to unfollow'

    delete('Unfollow user') do
      tags 'Follows'
      description 'Unfollow a user'
      produces 'application/json'
      security [ Bearer: [] ]

      response(200, 'successful') do
        schema type: :object,
               properties: {
                 success: { type: :boolean },
                 data: {
                   type: :object,
                   properties: {
                     message: { type: :string },
                     unfollow: { '$ref' => '#/components/schemas/Follow' }
                   }
                 }
               }

        let(:followee_id) { followee.id }
        let!(:follow) { create(:follow, follower: user, followee: followee) }

        run_test! do |response|
          expect(json_response['success']).to eq(true)
          expect(json_response['data']['message']).to be_present
          expect(json_response['data']['unfollow']).to be_present
        end
      end

      response(422, 'unprocessable_content') do
        schema '$ref' => '#/components/schemas/ErrorResponse'

        let(:followee_id) { followee.id }

        run_test! do |response|
          expect(json_response['success']).to eq(false)
          expect(json_response['error']['message']).to be_present
        end
      end

      response(401, 'unauthorized') do
        schema '$ref' => '#/components/schemas/ErrorResponse'
        let(:Authorization) { 'Bearer invalid_token' }
        let(:followee_id) { followee.id }
        run_test!
      end
    end
  end
end
