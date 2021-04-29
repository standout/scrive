# frozen_string_literal: true

RSpec.describe Scrive do
  it 'has a version number' do
    expect(Scrive::VERSION).not_to be nil
  end

  describe '.configure' do
    subject(:service) { described_class::EID.new }

    before do
      described_class.configure do |config|
        config.base_uri = 'test.url'
        config.token = 'abc123'
        config.debug = true
      end
    end

    it 'persist base url for new instances' do
      expect(service.base_uri).to eq('test.url')
    end

    it 'persist token for new instances' do
      expect(service.token).to eq('abc123')
    end

    it 'persist debug for new instances' do
      expect(service.debug).to be true
    end
  end
end
