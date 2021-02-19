# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BetterImageTag::ImageTag do
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

    context 'when passing `enabled: false`' do
      it 'skips the lazy-load work' do
        url = 'https://example.com/1x1.gif'

        result = tag(image: url).lazy_load(enabled: false).to_s

        expect(result).to eq %(<img src="#{url}" />)
      end
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
      VCR.use_cassette('remote_image') do
        url = 'https://png-pixel.com/1x1-ff00007f.png'
        result = tag(image: url).with_size.to_s

        expect(result).to eq %(<img width="1" height="1" src="#{url}" />)
      end
    end

    it "returns plain tag when remote url is 404'ing" do
      url = 'http://localhost/nothing.jpg'
      result = tag(image: url).with_size.to_s

      expect(result).to eq %(<img src="#{url}" />)
    end
  end

  describe '#webp' do
    it 'returns picture tag with webp in a source/srcset' do
      result = tag.webp.to_s

      expect(result).to eq <<~EOPICTURE
        <picture>
          <!--[if IE 9]><video style="display: none;"><![endif]-->
          <source srcset="/assets/1x1.webp" type="image/webp">
          <!--[if IE 9]></video><![endif]-->
          <img use_super="true" src="/assets/1x1.gif" />
        </picture>
      EOPICTURE
    end

    it 'uses the passed in webp url' do
      result = tag.webp('http://example.com/another.webp').to_s

      expect(result).to eq <<~EOPICTURE
        <picture>
          <!--[if IE 9]><video style="display: none;"><![endif]-->
          <source srcset="http://example.com/another.webp" type="image/webp">
          <!--[if IE 9]></video><![endif]-->
          <img use_super="true" src="/assets/1x1.gif" />
        </picture>
      EOPICTURE
    end

    context 'when using webp *and* avif' do
      it 'returns both formats in source tags' do
        result = tag.avif.webp.to_s

        expect(result).to eq <<~EOPICTURE
          <picture>
            <!--[if IE 9]><video style="display: none;"><![endif]-->
            <source srcset="/assets/1x1.avif" type="image/avif">
          <source srcset="/assets/1x1.webp" type="image/webp">
            <!--[if IE 9]></video><![endif]-->
            <img use_super="true" src="/assets/1x1.gif" />
          </picture>
        EOPICTURE
      end
    end

    context 'when lazily loading' do
      it 'does its lazy loading thing' do
        result = tag.webp.lazy_load.to_s
        data = 'data:image/gif;base64,R0lGODlhAQABAAAAACH5BAEKAAEALAAAAAABAAEAAAICTAEAOw=='

        expect(result).to eq <<~EOPICTURE
          <picture class="lazyload">
            <!--[if IE 9]><video style="display: none;"><![endif]-->
            <source data-srcset="/assets/1x1.webp" type="image/webp">
            <!--[if IE 9]></video><![endif]-->
            <img class="lazyload" data-src="/assets/1x1.gif" use_super="true" src="#{data}" />
          </picture>
        EOPICTURE
      end
    end
  end

  describe '#inline' do
    it 'inlines the contents of the target image' do
      result = tag.inline.to_s
      data = 'data:image/gif;base64,R0lGODlhAQABAIAAAAAAAP///yH5BAEAAAAALAAAAAABAAEAAAIBRAA7'

      expect(result).to include %(src="#{data}")
    end

    context 'when the image is an SVG' do
      it "inlines the svg directly without an image tag" do
        result = tag(image: 'sample.svg').inline.to_s

        expect(result).to start_with "<svg "
      end

      it "adds width and height to the inlined svg " do
        result = tag(
          image: 'sample.svg',
          options: { width: 10, height: 10 }
        ).inline.to_s

        expect(result).to start_with %(<svg width="10" height="10")
      end

      it "adds css class to the inlined svg" do
        result = tag(
          image: 'sample.svg',
          options: { class: "logo" }
        ).inline.to_s

        expect(result).to start_with %(<svg class="logo")
      end
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

  def tag(image: '1x1.gif', options: {})
    described_class.new(view_context, image, options).tap do |tag|
      allow(tag).to receive(:super_options).and_return({})
    end
  end
end
