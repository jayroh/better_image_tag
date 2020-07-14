# frozen_string_literal: true

require 'mimemagic'
require 'base64'
require 'open-uri'

module BetterImageTag
  class InlineData
    def self.inline_data(image)
      new(image).inline_data
    end

    attr_reader :image

    def initialize(image)
      @image = image
    end

    def inline_data
      return image unless BetterImageTag.configuration.inlining_enabled

      "data:#{content_type};base64,#{base64_contents}"
    end

    private

    def content_type
      MimeMagic.by_magic(contents).type
    end

    def base64_contents
      Base64.strict_encode64 contents
    end

    # rubocop:disable Security/Open
    def contents
      @_contents ||= begin
        if image.match?(%r{https?://})
          open(image).read
        elsif not_compiled?
          Rails.application.assets[image].to_s
        else
          Rails.application.assets_manifest.find_images(image).first
        end
      end
    end
    # rubocop:enable Security/Open

    def not_compiled?
      Rails.env.development? || Rails.env.test?
    end
  end
end