# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BetterImageTag::ImageTag do
  let(:view_context) do
    view_paths = ActionController::Base.view_paths
    lookup_context = ActionView::LookupContext.new(view_paths)
    ActionView::Base.new(lookup_context, {})
  end

  after do
    BetterImageTag.configure do |config|
      config.require_alt_tags = false
    end
  end

  describe '#to_s' do
    it 'returns an image tag' do
      tag = described_class.new(view_context, '1x1.gif').to_s

      expect(tag).to eq '<img src="/assets/1x1.gif" />'
    end

    it 'returns full url when passed URL' do
      tag = described_class.new(view_context, 'https://example.com/1.gif').to_s

      expect(tag).to eq '<img src="https://example.com/1.gif" />'
    end
  end

  describe '#with_size' do
    it 'returns image tag with size' do
      tag = described_class.new(view_context, '1x1.gif').with_size.to_s

      expect(tag).to eq '<img width="1" height="1" src="/assets/1x1.gif" />'
    end

    it 'returns image tag with size when using a remote url' do
      url = 'https://via.placeholder.com/1x1.png'
      tag = described_class.new(view_context, url).with_size.to_s

      expect(tag).to eq %(<img width="1" height="1" src="#{url}" />)
    end
  end

  context 'when requring alt tags for all images' do
    it 'raises an exception' do
      BetterImageTag.configure do |config|
        config.require_alt_tags = true
      end

      expect do
        described_class.new(view_context, '1x1.gif')
      end.to raise_error(BetterImageTag::Errors::MissingAltTag)
    end

    it 'does not raise an exception if alt tag is provided' do
      BetterImageTag.configure do |config|
        config.require_alt_tags = true
      end

      expect { described_class.new(view_context, '1x1.gif', alt: "gif") }
        .not_to raise_error
    end
  end
end
