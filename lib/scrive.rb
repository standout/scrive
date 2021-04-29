# frozen_string_literal: true

require_relative 'scrive/version'
require_relative 'scrive/eid'
require_relative 'scrive/configuration'

# Scrive module for underlying services
module Scrive
  class << self
    attr_writer :configuration

    def configuration
      @configuration ||= Configuration.new
    end

    def reset
      @configuration = nil
    end

    def configure
      yield(configuration)
    end
  end
end
