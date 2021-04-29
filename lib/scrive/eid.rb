# frozen_string_literal: true

require 'uri'
require 'net/http'
require 'json'

module Scrive
  # Client to connect to eID API
  class EID
    class TransactionNotCompletedError < StandardError; end

    class RateLimitError < StandardError; end

    class BadRequestError < StandardError; end

    attr_reader :token, :base_uri, :debug

    def initialize
      @token = Scrive.configuration.token
      @base_uri = Scrive.configuration.base_uri
      @debug = Scrive.configuration.debug
    end

    def new_transaction(redirect_url:)
      url = URI("#{base_uri}/transaction/new")

      request = Net::HTTP::Post.new(url)
      request['Authorization'] = authorization_header
      request['Content-Type'] = 'application/json'
      request.body = build_request_body(redirect_url)

      response = http(url).request(request)
      parse_response(response)
    end

    def get_transaction(transaction_id:)
      url = URI("#{base_uri}/transaction/#{transaction_id}")

      request = Net::HTTP::Get.new(url)
      request['Authorization'] = authorization_header

      response = parse_response(http(url).request(request))
      return response if response['status'].casecmp?('complete')

      raise TransactionNotCompletedError, response
    end

    private

    def ssn_path
      %w[providerInfo seBankID completionData user personalNumber]
    end

    def http(url)
      Net::HTTP.new(url.host, url.port).tap do |http|
        http.use_ssl = true
        http.set_debug_output $stderr if debug
        http.verify_mode = OpenSSL::SSL::VERIFY_PEER
      end
    end

    def build_request_body(redirect_url)
      {
        redirectUrl: redirect_url,
        provider: 'seBankID',
        method: 'auth'
      }.to_json
    end

    def parse_response(response)
      case response.code.to_i
      when (200..299) then JSON.parse(response.body)
      when 429 then raise RateLimitError, response.body
      else
        raise BadRequestError, response.body
      end
    end

    def authorization_header
      "Bearer #{token}"
    end
  end
end
