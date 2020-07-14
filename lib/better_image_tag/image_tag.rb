# frozen_string_literal: true

require 'fastimage'

module BetterImageTag
  class ImageTag
    attr_reader :request, :view_context, :options
    attr_accessor :image

    def initialize(request, view_context, image, options = {})
      @request = request
      @view_context = view_context
      @image = with_protocol(image)
      @options = options.symbolize_keys

      enforce_requirements
    end

    def with_size
      return self if options[:width].present? || options[:height].present?

      cache "image_tag:with_size:#{image}" do
        dimensions = FastImage.size(asset)
        options[:width] = dimensions&.first
        options[:height] = dimensions&.last
      end

      self
    end

    def lazy_load(placeholder: nil)
      options[:class] = Array(options.fetch(:class, [])).join(' ')
      options[:class] = "#{options[:class]} lazyload".strip
      options[:data] = options[:data]
                       .to_h
                       .merge(src: view_context.image_path(image))

      @image = 'data:image/gif;base64,R0lGODlhAQABAAAAACH5BAEKAAEALAAAAAABAAEAAAICTAEAOw=='

      self
    end

    def webp
      if image.match?(/^data:/)
        raise EarlyLazyLoad, 'Run lazy_load as the last method in chain'
      end

      self.image = image.gsub(/\.[a-z]{2,}*\z/, '.webp') if accepts_webp?

      self
    end

    def to_s
      view_context.image_tag(image, options.merge(super_options))
    end

    private

    def super_options
      { use_super: true }
    end

    def accepts_webp?
      @_accepts_webp ||= request&.headers['HTTP_ACCEPT'].to_s.match?('image/webp')
    end

    def with_protocol(image)
      image.match?(%r{^//}) ? "https:#{image}" : image
    end

    def asset
      @_asset ||= begin
        if image.match?(%r{https?://})
          image
        elsif not_compiled?
          Rails.application.assets[image].filename
        else
          Rails.application.assets_manifest.find_images(image).first
        end
      end
    end

    def not_compiled?
      Rails.env.development? || Rails.env.test?
    end

    def enforce_requirements
      if BetterImageTag.configuration&.require_alt_tags && options[:alt].blank?
        raise Errors::MissingAltTag, "#{image} is missing an alt tag"
      end
    end

    def cache(tag, &block)
      return unless block
      return block.call unless BetterImageTag.configuration&.cache_enabled

      Rails.cache.fetch tag, &block
    end
  end
end
