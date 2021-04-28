# frozen_string_literal: true

require 'json'

RSpec.describe Scrive::EID do
  let(:service) { described_class.new(token: token, base_uri: base_uri) }
  let(:http_request_headers) { { 'Authorization' => "Bearer #{token}" } }
  let(:token) { 'valid_token' }
  let(:base_uri) { 'https://testbed-eid.scrive.com/api/v1' }

  describe '#new_transaction' do
    subject(:new_transaction) do
      service.new_transaction(redirect_url: 'https://bogus.host')
    end

    let(:http_request_body) do
      {
        redirectUrl: 'https://bogus.host',
        provider: 'seBankID',
        method: 'auth'
      }.to_json
    end

    let(:http_response) do
      File.read('spec/fixtures/files/new_transaction_response.json')
    end
    let(:response_code) { 200 }

    let(:request) do
      stub_request(:post,
                   'https://testbed-eid.scrive.com/api/v1/transaction/new')
        .with(headers: http_request_headers, body: http_request_body)
        .to_return(status: response_code, body: http_response, headers: {})
    end

    before { request }

    it 'makes a request to the uri' do
      new_transaction

      expect(request).to have_been_requested
    end

    it 'returns the parsed response' do
      expect(new_transaction).to eq(JSON.parse(http_response))
    end

    context 'when response code is not 200' do
      let(:response_code) { 401 }

      it 'raises bad request error' do
        expect { new_transaction }
          .to raise_error(described_class::BadRequestError)
      end
    end

    context 'when response code is 429' do
      let(:response_code) { 429 }

      it 'raises bad request error' do
        expect { new_transaction }
          .to raise_error(described_class::RateLimitError)
      end
    end
  end

  describe '#get_transaction?' do
    subject(:get_transaction) do
      service.get_transaction(transaction_id: 1234)
    end

    let(:ssn) { 196_309_125_422 }

    let(:request) do
      stub_request(:get,
                   'https://testbed-eid.scrive.com/api/v1/transaction/1234')
        .with(headers: http_request_headers, body: '')
        .to_return(status: 200, body: http_response.to_json, headers: {})
    end
    let(:http_response) do
      JSON.parse(File.read('spec/fixtures/files/get_transaction_response.json'))
    end

    context 'when status is completed' do
      before { request }

      it 'makes a request to the uri' do
        get_transaction

        expect(request).to have_been_requested
      end

      it 'returns transaction response' do
        expect(get_transaction).to eq(http_response)
      end
    end

    context 'when status is not complete' do
      before do
        http_response['status'] = 'failed'
        request
      end

      it 'raises not completed error' do
        expect { get_transaction }
          .to raise_error(described_class::TransactionNotCompletedError)
      end
    end
  end
end
