# frozen_string_literal: true

module BetterImageTag
  class BaseImageTag
    attr_reader :view_context, :options, :image

    def initialize(view_context, image, options = {})
      @view_context = view_context
      @image = image
      @options = options.symbolize_keys
    end

    def with_size
      self
    end

    def lazy_load(**_args)
      self
    end

    def webp
      self
    end

    def avif
      self
    end

    def inline
      self
    end

    def to_s
      view_context.image_tag(image, options.merge(use_super: true))
    end
  end
end
