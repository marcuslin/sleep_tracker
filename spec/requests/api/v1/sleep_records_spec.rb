require 'swagger_helper'

RSpec.describe 'api/v1/sleep_records', type: :request do
  let(:user) { create(:user) }
  let(:token) { Auth::JwtService.encode(user_id: user.id) }
  let(:Authorization) { "Bearer #{token}" }

  path '/api/v1/sleep_records' do
    get('List sleep records') do
      tags 'Sleep Records'
      description 'Retrieve all personal sleep records with cursor-based pagination'
      produces 'application/json'
      security [ Bearer: [] ]

      parameter name: :cursor, in: :query, type: :string, required: false, description: 'Cursor for pagination'
      parameter name: :limit, in: :query, type: :integer, required: false, description: 'Number of records to return (default: 20)'

      response(200, 'successful') do
        schema type: :object,
               properties: {
                 success: { type: :boolean },
                 data: {
                   type: :array,
                   items: { '$ref' => '#/components/schemas/SleepRecord' }
                 },
                 meta: {
                   type: :object,
                   properties: {
                     next_cursor: { type: :string, nullable: true }
                   }
                 }
               }

        context 'when user has sleep records' do
          let!(:records) { create_list(:sleep_record, 3, user: user, status: :awake) }

          run_test! do |response|
            expect(json_response['success']).to be true
            expect(json_response['data']).to be_an(Array)
            expect(json_response['data'].length).to eq(3)
            expect(json_response['meta']).to have_key('next_cursor')
          end
        end
      end

      response(401, 'unauthorized') do
        schema '$ref' => '#/components/schemas/ErrorResponse'
        let(:Authorization) { 'Bearer invalid_token' }
        run_test!
      end
    end
  end

  path '/api/v1/sleep_records/clock_in' do
    post('Clock in') do
      tags 'Sleep Records'
      description 'Record the start of a sleep session'
      produces 'application/json'
      security [ Bearer: [] ]

      response(201, 'created') do
        schema type: :object,
               properties: {
                 success: { type: :boolean },
                 data: {
                   type: :object,
                   properties: {
                     new_record: { '$ref' => '#/components/schemas/SleepRecord' },
                     sleep_records: {
                       type: :array,
                       items: { '$ref' => '#/components/schemas/SleepRecord' }
                     }
                   }
                 }
               }

        run_test! do |response|
          expect(json_response['success']).to eq(true)
          expect(json_response['data']['new_record']).to be_present
          expect(json_response['data']['new_record']['status']).to eq('sleeping')
        end
      end

      response(422, 'unprocessable_content') do
        schema '$ref' => '#/components/schemas/ErrorResponse'

        context 'when user already has active sleep record' do
          before { create(:sleep_record, user: user, status: 'sleeping') }

          run_test! do |response|
            expect(json_response['success']).to eq(false)
            expect(json_response['error']['message']).to be_present
          end
        end
      end

      response(401, 'unauthorized') do
        schema '$ref' => '#/components/schemas/ErrorResponse'
        let(:Authorization) { 'Bearer invalid_token' }
        run_test!
      end
    end
  end

  path '/api/v1/sleep_records/clock_out' do
    post('Clock out') do
      tags 'Sleep Records'
      description 'Record the end of a sleep session'
      produces 'application/json'
      security [ Bearer: [] ]

      response(200, 'successful') do
        schema type: :object,
               properties: {
                 success: { type: :boolean },
                 data: {
                   type: :object,
                   properties: {
                     sleep_record: { '$ref' => '#/components/schemas/SleepRecord' }
                   }
                 }
               }

        context 'when user has active sleep record' do
          let!(:sleep_record) { create(:sleep_record, user: user, status: 'sleeping') }

          run_test! do |response|
            expect(json_response['success']).to eq(true)
            expect(json_response['data']['sleep_record']).to be_present
            expect(json_response['data']['sleep_record']['status']).to eq('awake')
            expect(json_response['data']['sleep_record']['duration']).to be_present
          end
        end
      end

      response(422, 'unprocessable_content') do
        schema '$ref' => '#/components/schemas/ErrorResponse'

        run_test! do |response|
          expect(json_response['success']).to eq(false)
          expect(json_response['error']['message']).to be_present
        end
      end

      response(401, 'unauthorized') do
        schema '$ref' => '#/components/schemas/ErrorResponse'
        let(:Authorization) { 'Bearer invalid_token' }
        run_test!
      end
    end
  end

  path '/api/v1/sleep_records/friends_weekly' do
    get('Friends weekly sleep records') do
      tags 'Sleep Records'
      description 'Get friends\' sleep records from the previous week, sorted by duration'
      produces 'application/json'
      security [ Bearer: [] ]

      parameter name: :cursor, in: :query, type: :string, required: false, description: 'Cursor for pagination'
      parameter name: :limit, in: :query, type: :integer, required: false, description: 'Number of records to return (default: 20)'

      response(200, 'successful') do
        schema type: :object,
               properties: {
                 success: { type: :boolean },
                 data: {
                   type: :array,
                   items: { '$ref' => '#/components/schemas/SleepRecord' }
                 },
                 meta: {
                   type: :object,
                   properties: {
                     next_cursor: { type: :string, nullable: true }
                   }
                 }
               }

        context 'when friends have sleep records' do
          let(:friend) { create(:user) }
          let!(:follow) { create(:follow, follower: user, followee: friend) }
          let!(:friend_sleep_record) do
            create(:sleep_record,
                   user: friend,
                   status: 'awake',
                   duration: 8.hours.to_i,
                   created_at: 1.week.ago + 1.day)
          end

          run_test! do |response|
            expect(json_response['success']).to eq(true)
            expect(json_response['data']).to be_an(Array)
            expect(json_response['meta']).to have_key('next_cursor')
          end
        end
      end

      response(401, 'unauthorized') do
        schema '$ref' => '#/components/schemas/ErrorResponse'
        let(:Authorization) { 'Bearer invalid_token' }
        run_test!
      end
    end
  end
end
