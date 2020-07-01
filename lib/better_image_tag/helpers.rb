# frozen_string_literal: true

module BetterImageTag
  module Helpers
    def image_tag
      original_method = options.delete(:original_image_tag)

      if original_method
        super(source, options)
      else
        BetterImageTag::ImageTag.new(self, source)
      end
    end
  end
end
