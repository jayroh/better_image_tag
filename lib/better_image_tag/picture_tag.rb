# frozen_string_literal: true

require 'forwardable'

module BetterImageTag
  class PictureTag
    attr_reader :image_tag, :default_image_tag, :sources, :srcset

    extend Forwardable
    def_delegators :image_tag, :image, :images, :view_context
    def_delegators :view_context, :image_path
    def_delegators :config, :tablet_breakpoint, :desktop_breakpoint

    def initialize(image_tag, default_image_tag)
      @image_tag = image_tag
      @default_image_tag = default_image_tag
      @sources = []
    end

    def to_s
      output(:lazily) || output(:normally)
    end

    private

    def config
      BetterImageTag.configuration
    end

    def output(loading_style)
      return if loading_style == :lazily && image != ImageTag::TRANSPARENT_GIF
      @srcset = loading_style == :lazily ? 'data-srcset' : 'srcset'
      css_class = css_class? ? %( class="#{image_tag.options[:class]}--picture") : ''

      populate_responsive_and_format_sources
      populate_responsive_sources
      populate_format_sources

      <<~EOPICTURE
        <picture#{css_class}>
          <!--[if IE 9]><video style="display: none;"><![endif]-->
          #{sources.join("\n  ")}
          <!--[if IE 9]></video><![endif]-->
          #{default_image_tag}
        </picture>
      EOPICTURE
    end

    def css_class?
      image_tag.options[:class].present?
    end

    def populate_responsive_and_format_sources
      if image_tag.tablet_options&.second
        if image_tag.tablet_options.second[:avif]
          @sources << %(<source media="(min-width: #{tablet_breakpoint})" type="image/avif" #{srcset}="#{image_path image_tag.tablet_options.second[:avif]}">)
        end

        if image_tag.tablet_options.second[:webp]
          @sources << %(<source media="(min-width: #{tablet_breakpoint})" type="image/webp" #{srcset}="#{image_path image_tag.tablet_options.second[:webp]}">)
        end
      end

      if image_tag.desktop_options&.second
        if image_tag.desktop_options.second[:avif]
          @sources << %(<source media="(min-width: #{desktop_breakpoint})" type="image/avif" #{srcset}="#{image_path image_tag.desktop_options.second[:avif]}">)
        end

        if image_tag.desktop_options.second[:webp]
          @sources << %(<source media="(min-width: #{desktop_breakpoint})" type="image/webp" #{srcset}="#{image_path image_tag.desktop_options.second[:webp]}">)
        end
      end
    end

    def populate_format_sources
      return if images.empty?

      @sources += images.map do |image|
        type = image.match?(/webp$/) ? 'webp' : 'avif'
        %(<source type="image/#{type}" #{srcset}="#{image_path image}">)
      end
    end

    def populate_responsive_sources
      return if image_tag.tablet_options.blank? && image_tag.desktop_options.blank?

      if image_tag.tablet_options
        @sources << %(<source media="(min-width: #{tablet_breakpoint})" #{srcset}="#{image_path image_tag.tablet_options.first}">)
      end

      if image_tag.desktop_options
        @sources << %(<source media="(min-width: #{desktop_breakpoint})" #{srcset}="#{image_path image_tag.desktop_options.first}">)
      end
    end
  end
end
