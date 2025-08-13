require 'rails_helper'
require 'rswag/specs'

RSpec.configure do |config|
  config.openapi_root = Rails.root.join('swagger').to_s

  config.openapi_specs = {
    'v1/swagger.yaml' => {
      openapi: '3.0.1',
      info: {
        title: 'Sleep Tracker API V1',
        version: 'v1',
        description: 'API for tracking sleep records and managing social connections'
      },
      paths: {},
      servers: [
        {
          url: 'http://localhost:3000',
          description: 'Development server'
        }
      ],
      components: {
        securitySchemes: {
          Bearer: {
            type: :http,
            scheme: :bearer,
            bearerFormat: 'JWT'
          }
        },
        schemas: {
          User: {
            type: :object,
            properties: {
              id: { type: :integer },
              name: { type: :string }
            }
          },
          SleepRecord: {
            type: :object,
            properties: {
              id: { type: :integer },
              user_id: { type: :integer },
              user_name: { type: :string },
              duration: { type: :number, nullable: true },
              status: { type: :string },
              clock_in_time: { type: :string, format: 'date-time' },
              clock_out_time: { type: :string, format: 'date-time', nullable: true },
              created_at: { type: :string, format: 'date-time' }
            }
          },
          Follow: {
            type: :object,
            properties: {
              id: { type: :integer },
              user_id: { type: :integer },
              followee_id: { type: :integer },
              created_at: { type: :string, format: 'date-time' }
            }
          },
          ErrorResponse: {
            type: :object,
            properties: {
              success: { type: :boolean },
              error: {
                type: :object,
                properties: {
                  message: { type: :string }
                }
              }
            }
          }
        }
      }
    }
  }

  config.openapi_format = :yaml
end
