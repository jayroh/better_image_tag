# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BetterImageTag::ImageTag do
  let(:default_request) { double('request', headers: {}) }

  let(:view_context) do
    view_paths = ActionController::Base.view_paths
    lookup_context = ActionView::LookupContext.new(view_paths)
    ActionView::Base.new(lookup_context, {})
  end

  before do
    BetterImageTag.configure do |config|
      config.require_alt_tags = false
    end
  end

  describe '#to_s' do
    it 'returns an image tag' do
      result = tag.to_s

      expect(result).to eq '<img src="/assets/1x1.gif" />'
    end

    it 'returns full url when passed URL' do
      result = tag(image: 'https://example.com/1.gif').to_s

      expect(result).to eq '<img src="https://example.com/1.gif" />'
    end
  end

  describe '#lazy_load' do
    it 'inlines a transparent gif and sets src on data attribute' do
      data = 'data:image/gif;base64,R0lGODlhAQABAAAAACH5BAEKAAEALAAAAAABAAEAAAICTAEAOw=='
      result = tag.lazy_load.to_s

      expect(result).to include %(class="lazyload")
      expect(result).to include %(data-src="/assets/1x1.gif")
      expect(result).to include %(src="#{data}")
    end

    it 'inlines transparent gif and uses full url in data-src' do
      url = 'https://example.com/1x1.gif'
      data = 'data:image/gif;base64,R0lGODlhAQABAAAAACH5BAEKAAEALAAAAAABAAEAAAICTAEAOw=='
      result = tag(image: url).lazy_load.to_s

      expect(result).to eq %(<img class="lazyload" data-src="#{url}" src="#{data}" />)
    end
  end

  describe '#with_size' do
    it 'returns image tag with size' do
      result = tag.with_size.to_s

      expect(result).to eq '<img width="1" height="1" src="/assets/1x1.gif" />'
    end

    it 'defaults to the sizes provided' do
      result = tag(options: { width: 10, height: 10 }).with_size.to_s

      expect(result).to eq '<img width="10" height="10" src="/assets/1x1.gif" />'
    end

    it 'returns image tag with size when using a remote url' do
      url = 'https://via.placeholder.com/1x1.png'
      result = tag(image: url).with_size.to_s

      expect(result).to eq %(<img width="1" height="1" src="#{url}" />)
    end
  end

  describe '#webp' do
    it 'returns the webp version of an image when browser supports it' do
      request = double('request', headers: { 'HTTP_ACCEPT' => 'image/webp' })
      result = tag(request: request).webp.to_s

      expect(result).to eq '<img src="/assets/1x1.webp" />'
    end

    it "doesn't return webp version of image when browser doesn't support it" do
      request = double('request', headers: { 'HTTP_ACCEPT' => 'image/gif' })
      result = tag(request: request).webp.to_s

      expect(result).to eq '<img src="/assets/1x1.gif" />'
    end
  end

  context 'when requiring alt tags for all images' do
    before do
      BetterImageTag.configure do |config|
        config.require_alt_tags = true
      end
    end

    it 'raises an exception' do
      expect { tag }.to raise_error(BetterImageTag::Errors::MissingAltTag)
    end

    it 'does not raise an exception if alt tag is provided' do
      expect { tag(options: { alt: 'description' }) }.not_to raise_error
    end
  end

  def tag(request: default_request, image: '1x1.gif', options: {})
    described_class.new(request, view_context, image, options).tap do |tag|
      allow(tag).to receive(:super_options).and_return({})
    end
  end
end
