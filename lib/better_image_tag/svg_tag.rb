# frozen_string_literal: true

module BetterImageTag
  class SvgTag
    attr_reader :image_tag

    def initialize(image_tag)
      @image_tag = image_tag
    end

    def to_s
      image_tag.image = image_tag.image.gsub(/^<svg/, %(<svg height="#{height}")) if height
      image_tag.image = image_tag.image.gsub(/^<svg/, %(<svg width="#{width}")) if width
      image_tag.image = image_tag.image.gsub(/^<svg/, %(<svg #{data})) if data
      image_tag.image = image_tag.image.gsub(/^<svg/, %(<svg class="#{css_class}")) if css_class
      image_tag.image
    end

    private

    def width
      image_tag.options[:width]
    end

    def height
      image_tag.options[:height]
    end

    def css_class
      image_tag.options[:class]
    end

    def data
      @data ||= begin
        return unless image_tag.options[:data]

        image_tag
          .options[:data]
          .transform_keys { |k| "data_#{k}" }
          .map { |key, val| %(#{key.gsub('_', '-')}="#{val}") }
          .join(' ')
      end
    end
  end
end
