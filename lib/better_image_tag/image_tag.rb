# frozen_string_literal: true

require 'fastimage'

module BetterImageTag
  class ImageTag
    attr_reader :view_context, :image, :options

    def initialize(view_context, image, options = {})
      @view_context = view_context
      @image = with_protocol(image)
      @options = options.symbolize_keys

      enforce_requirements
    end

    def with_size
      return self if options[:width].present? || options[:height].present?

      Rails.cache.fetch "image_tag:with_size:#{image}" do
        dimensions = FastImage.size(asset)
        options[:width] = dimensions&.first
        options[:height] = dimensions&.last
      end

      self
    end

    def lazy_load(placeholder: nil)
      placeholder ||= 'data:image/gif;base64,R0lGODlhAQABAAAAACH5BAEKAAEALAAAAAABAAEAAAICTAEAOw=='

      options[:class] = Array(options.fetch(:class, [])).join(' ')
      options[:class] = "#{options[:class]} lazyload".strip

      data_attribs = { src: view_context.image_path(image) }
      options[:data] = options[:data].to_h.merge(data_attribs)

      view_context.image_tag(placeholder, options)
    end

    def to_s
      view_context.image_tag(image, options)
    end

    private

    def with_protocol(src)
      src.match?(%r{^//}) ? "https:#{src}" : src
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
  end
end
