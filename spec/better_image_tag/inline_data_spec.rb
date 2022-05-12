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
        VCR.use_cassette("remote_image") do
          url = 'https://png-pixel.com/1x1-ff00007f.png'
          result = BetterImageTag::InlineData.inline_data(url)

          expect(result).to match(%r{data:image/png})
        end
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

    context 'when there is a network error' do
      it 'returns the original image src when ssl error' do
        url = 'http://localhost/nothing.jpg'
        inliner = BetterImageTag::InlineData.new(url)
        allow(URI).to receive(:open).and_raise(OpenSSL::SSL::SSLError)

        result = inliner.inline_data

        expect(result).to eq(url)
      end

      it 'returns the original image src when http error' do
        url = 'http://localhost/nothing.jpg'
        inliner = BetterImageTag::InlineData.new(url)
        error = OpenURI::HTTPError.new 'error', nil
        allow(URI).to receive(:open).and_raise(error)

        result = inliner.inline_data

        expect(result).to eq(url)
      end
    end
  end
end
