# frozen_string_literal: true

require 'nokogiri'

module BetterImageTag
  class SvgTag
    DANGEROUS_ELEMENTS = %w[script foreignObject].freeze
    DANGEROUS_ATTRIBUTES = %w[onload onclick onerror onmouseover].freeze

    attr_reader :image_tag

    def initialize(image_tag)
      @image_tag = image_tag
    end

    def to_s
      sanitize_and_modify_svg
    rescue Nokogiri::XML::SyntaxError => e
      handle_error(e)
      # Return a safe empty SVG on parse error
      '<svg></svg>'
    end

    private

    def sanitize_and_modify_svg
      doc = parse_svg
      svg_element = doc.at_css('svg')

      unless svg_element
        raise BetterImageTag::Errors::InvalidSvgError, 'No SVG element found'
      end

      sanitize_svg(doc)
      apply_attributes(svg_element)

      doc.to_html
    end

    def parse_svg
      Nokogiri::XML(image_tag.image) do |config|
        config.strict.nonet.noblanks
      end
    end

    def sanitize_svg(doc)
      # Remove dangerous elements
      DANGEROUS_ELEMENTS.each do |element|
        doc.css(element).remove
      end

      # Remove dangerous attributes from all elements
      doc.css('*').each do |element|
        DANGEROUS_ATTRIBUTES.each do |attr|
          element.remove_attribute(attr)
        end
      end
    end

    def apply_attributes(svg_element)
      svg_element['width'] = width if width
      svg_element['height'] = height if height
      svg_element['class'] = css_class if css_class
    end

    def width
      image_tag.options[:width]
    end

    def height
      image_tag.options[:height]
    end

    def css_class
      image_tag.options[:class]
    end

    def handle_error(error)
      callback = BetterImageTag.configuration.on_error
      callback&.call(error, image: image_tag.image, operation: :svg_parse)
    end
  end
end
