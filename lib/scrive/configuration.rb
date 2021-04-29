# frozen_string_literal: true

module Scrive
  # Configuration for Scrive
  class Configuration
    attr_accessor :base_uri, :token, :debug

    def initialize
      @base_uri = nil
      @token = nil
      @debug = false
    end
  end
end
