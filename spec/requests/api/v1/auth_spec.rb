require 'swagger_helper'

RSpec.describe 'api/v1/auth', type: :request do
  path '/api/v1/auth/login' do
    post('Login user') do
      tags 'Authentication'
      description 'Authenticate a user and receive a JWT token'
      consumes 'application/json'
      produces 'application/json'

      parameter name: :auth_params, in: :body, schema: {
        type: :object,
        properties: {
          user_id: { type: :integer, description: 'User ID to authenticate' }
        },
        required: [ 'user_id' ]
      }

      response(200, 'successful') do
        schema type: :object,
               properties: {
                 success: { type: :boolean },
                 data: {
                   type: :object,
                   properties: {
                     token: { type: :string, description: 'JWT authentication token' },
                     user: { '$ref' => '#/components/schemas/User' }
                   }
                 }
               }

        let(:user) { create(:user) }
        let(:auth_params) { { user_id: user.id } }

        run_test! do |response|
          expect(json_response['success']).to eq(true)
          expect(json_response['data']['token']).to be_present
          expect(json_response['data']['user']['id']).to eq(user.id)
        end
      end

      response(401, 'unauthorized') do
        schema '$ref' => '#/components/schemas/ErrorResponse'

        let(:auth_params) { { user_id: 99999 } }

        run_test! do |response|
          expect(json_response['success']).to eq(false)
          expect(json_response['error']['message']).to eq('Access denied')
        end
      end
    end
  end
end
