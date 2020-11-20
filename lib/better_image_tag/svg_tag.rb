# frozen_string_literal: true

module BetterImageTag
  class SvgTag
    attr_reader :image_tag

    def initialize(image_tag)
      @image_tag = image_tag
    end

    def to_s
      image_tag.image.gsub!(/^\<svg /, %(<svg height="#{height}" )) if height
      image_tag.image.gsub!(/^\<svg /, %(<svg width="#{width}" )) if width

      image_tag.image
    end

    private

    def width
      image_tag.options[:width]
    end

    def height
      image_tag.options[:height]
    end
  end
end
