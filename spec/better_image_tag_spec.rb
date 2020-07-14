# frozen_string_literal: true

require 'spec_helper'

RSpec.describe BetterImageTag do
  it 'has a version number' do
    expect(BetterImageTag::VERSION).not_to be nil
  end

  describe BetterImageTag::Configuration do
    it 'can congigure the gem with a block' do
      BetterImageTag.configure do |config|
        config.require_alt_tags = true
      end

      expect(BetterImageTag.configuration.require_alt_tags).to eq true
    end

    it 'can configure the gem with a setter' do
      BetterImageTag.configuration.require_alt_tags = false

      expect(BetterImageTag.configuration.require_alt_tags).to eq false
    end
  end
end
