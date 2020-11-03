# frozen_string_literal: true

require 'fastimage'

module BetterImageTag
  class ImageTag
    TRANSPARENT_GIF = 'data:image/gif;base64,R0lGODlhAQABAAAAACH5BAEKAAEALAAAAAABAAEAAAICTAEAOw=='

    attr_reader :view_context, :options, :images
    attr_accessor :image

    def initialize(view_context, image, options = {})
      @view_context = view_context
      @image = with_protocol(image)
      @options = options.symbolize_keys
      @images = []

      enforce_requirements
    end

    def with_size
      return self if options[:width].present? || options[:height].present?

      dims = cache("image_tag:with_size:#{image}") { FastImage.size(asset) }
      options[:width] = dims&.first
      options[:height] = dims&.last

      self
    end

    def lazy_load(placeholder: nil)
      options[:class] = Array(options.fetch(:class, [])).join(' ')
      options[:class] = "#{options[:class]} lazyload".strip
      options[:data] = options[:data]
                       .to_h
                       .merge(src: view_context.image_path(image))

      @image = TRANSPARENT_GIF

      self
    end

    def webp
      lazy_load_last!
      @images << image.gsub(/\.[a-z]{2,}*\z/, '.webp')
      self
    end

    def avif
      lazy_load_last!
      @images << image.gsub(/\.[a-z]{2,}*\z/, '.avif')
      self
    end

    def inline
      @image = InlineData.new(@image).inline_data

      self
    end

    def to_s
      result = view_context.image_tag(image, options.merge(super_options))
      return result if images.empty?

      BetterImageTag::PictureTag.new(self, result).to_s
    end

    private

    def lazy_load_last!
      return unless image.match?(/^data:/)

      raise EarlyLazyLoad, 'Run lazy_load as the last method in chain'
    end

    def super_options
      { use_super: true }
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
      if BetterImageTag.configuration.require_alt_tags && options[:alt].blank?
        raise Errors::MissingAltTag, "#{image} is missing an alt tag"
      end
    end

    def cache(tag, &block)
      return unless block

      return block.call unless BetterImageTag.configuration.cache_sizing_enabled

      Rails.cache.fetch tag, &block
    end
  end
end
