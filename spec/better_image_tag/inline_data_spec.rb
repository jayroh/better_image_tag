# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BetterImageTag::InlineData do
  after do
    BetterImageTag.configure do |config|
      config.inlining_enabled = true
    end
  end

  describe '.inline_data' do
    context 'when requesting external image' do
      it 'returns base64 encoded inline data' do
        url = 'https://via.placeholder.com/1x1.png'
        result = BetterImageTag::InlineData.inline_data(url)

        expect(result).to match(%r{data:image/png})
      end
    end

    context 'when inlining an image in asset pipeline' do
      it 'returns base64 encoded inline data' do
        result = BetterImageTag::InlineData.inline_data('1x1.gif')
        data = 'data:image/gif;base64,'\
          'R0lGODlhAQABAIAAAAAAAP///yH5BAEAAAAALAAAAAABAAEAAAIBRAA7'

        expect(result).to eq data
      end
    end

    context 'when inlining is disabled' do
      it 'returns the original image src' do
        BetterImageTag.configure do |config|
          config.inlining_enabled = false
        end

        result = BetterImageTag::InlineData.inline_data('1x1.gif')

        expect(result).to eq('1x1.gif')
      end
    end
  end
end