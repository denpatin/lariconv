# frozen_string_literal: true

require_relative '../lib/lariconv'

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
end

# Helper to build a fake NBG API JSON response
def nbg_api_response(code:, quantity: 1, rate:)
  JSON.generate([{
    'date' => '2025-01-15T00:00:00.000Z',
    'currencies' => [{
      'code' => code,
      'quantity' => quantity,
      'rateFormated' => rate.to_s,
      'diffFormated' => '0.0100',
      'rate' => rate,
      'name' => 'Test Currency',
      'diff' => 0.01,
      'date' => '2025-01-14T17:01:03.879Z',
      'validFromDate' => '2025-01-15T00:00:00.000Z'
    }]
  }])
end

# Stub the HTTP call and return fake JSON
def stub_nbg_api(response_body)
  uri_double = instance_double(URI::HTTPS)
  allow(URI).to receive(:parse).and_call_original
  allow(URI).to receive(:parse).with(/nbg\.gov\.ge/).and_return(uri_double)
  allow(uri_double).to receive(:read).and_return(response_body)
  uri_double
end
