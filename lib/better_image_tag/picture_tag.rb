# frozen_string_literal: true

require 'forwardable'

module BetterImageTag
  class PictureTag
    attr_reader :image_tag, :default_image_tag

    extend Forwardable
    def_delegators :image_tag, :image, :images, :view_context
    def_delegators :view_context, :image_path

    def initialize(image_tag, default_image_tag)
      @image_tag = image_tag
      @default_image_tag = default_image_tag
    end

    def to_s
      output(:lazily) || output(:normally)
    end

    private

    def output(loading_style)
      return if loading_style == :lazily && image != ImageTag::TRANSPARENT_GIF

      srcset = loading_style == :lazily ? 'data-srcset' : 'srcset'

      css_class = css_class? ? %( class="#{image_tag.options[:class]}") : ''

      sources = images.map do |image|
        type = image.match?(/webp$/) ? 'webp' : 'avif'
        %(<source #{srcset}="#{image_path image}" type="image/#{type}">)
      end.join("\n")


      <<~EOPICTURE
        <picture#{css_class}>
          <!--[if IE 9]><video style="display: none;"><![endif]-->
          #{sources}
          <!--[if IE 9]></video><![endif]-->
          #{default_image_tag}
        </picture>
      EOPICTURE
    end

    def css_class?
      image_tag.options[:class].present?
    end
  end
end
