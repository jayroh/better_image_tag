# frozen_string_literal: true

require 'fastimage'

module BetterImageTag
  class ImageTag
    TRANSPARENT_GIF = 'data:image/gif;base64,R0lGODlhAQABAAAAACH5BAEKAAEALAAAAAABAAEAAAICTAEAOw=='

    attr_reader :view_context, :options, :images, :tablet_options, :desktop_options
    attr_accessor :image

    def initialize(view_context, image, options = {})
      @view_context = view_context
      @image = with_protocol(image)
      @images = []
      @options = options.symbolize_keys

      avif(@options[:avif]) if @options[:avif]
      webp(@options[:webp]) if @options[:webp]
      enforce_requirements
    end

    def with_size
      return self if options[:width].present? || options[:height].present?
      return self unless BetterImageTag.configuration.sizing_enabled

      dims = cache("image_tag:with_size:#{image}") { FastImage.size(asset) }
      options[:width] = dims&.first
      options[:height] = dims&.last

      self
    end

    # rubocop:disable Metrics/AbcSize
    def lazy_load(enabled: true)
      return self unless enabled

      options[:class] = Array(options.fetch(:class, [])).join(' ')
      options[:class] = "#{options[:class]} lazyload".strip
      options[:data] = options[:data]
                       .to_h
                       .merge(src: view_context.image_path(image))

      @image = TRANSPARENT_GIF

      self
    end
    # rubocop:enable Metrics/AbcSize

    def webp(url = nil)
      lazy_load_last!
      @images << (url || image.gsub(/\.[a-z]{2,}*\z/, '.webp'))
      self
    end

    def avif(url = nil)
      lazy_load_last!
      @images << (url || image.gsub(/\.[a-z]{2,}*\z/, '.avif'))
      self
    end

    def inline
      @image = InlineData.new(@image).inline_data

      self
    end

    def to_s
      (svg_string || image_tag_string || picture_tag_string).html_safe
    end

    def picture_tag
      result = view_context.image_tag(
        image,
        options.except(:webp, :avif).merge(use_super: true)
      )
      PictureTag.new(self, result)
    end

    def tablet_up(*tablet_options)
      @tablet_options = tablet_options
      self
    end

    def desktop_up(*desktop_options)
      @desktop_options = desktop_options
      self
    end

    private

    def svg_string
      return unless svg?

      SvgTag.new(self).to_s
    end

    def image_tag_string
      return if images.any? || tablet_options&.any? || desktop_options&.any?

      view_context.image_tag(
        image,
        options.except(:webp, :avif).merge(super_options)
      )
    end

    def picture_tag_string
      picture_tag.to_s
    end

    def svg?
      MimeMagic.by_magic(@image)&.type == 'image/svg+xml'
    end

    def super_options
      if images.any?
        { use_picture: true }
      else
        { use_super: true }
      end
    end

    def lazy_load_last!
      return unless image.match?(/^data:/)

      raise EarlyLazyLoad, 'Run lazy_load as the last method in chain'
    end

    def with_protocol(image)
      image.match?(%r{^//}) ? "https:#{image}" : image
    end

    def asset
      @_asset ||= begin
        if image.match?(%r{https?://}) || !Object.const_defined?(:Rails)
          image
        elsif not_compiled?
          Rails.application.assets[image].filename
        else
          file = Rails.application.assets_manifest.assets[image]

          if file.nil?
            raise(
              BetterImageTag::Errors::FileNotFound,
              "Not found in asset manifest: #{image}"
            )
          end

          File.join(Rails.application.assets_manifest.directory, file)
        end
      end
    end

    def not_compiled?
      !!Rails.application.assets
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
