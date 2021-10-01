# frozen_string_literal: true

require 'mimemagic'
require 'base64'
require 'open-uri'

module BetterImageTag
  class InlineData
    HTTP_ERRORS = [
      EOFError,
      Errno::ECONNREFUSED,
      Errno::ECONNRESET,
      Errno::EINVAL,
      Net::HTTPBadResponse,
      Net::HTTPHeaderSyntaxError,
      Net::ProtocolError,
      Timeout::Error,
      OpenSSL::SSL::SSLError,
      OpenURI::HTTPError
    ].freeze

    CACHE_PREFIX = 'inline_data'

    def self.inline_data(*args)
      new(*args).inline_data
    end

    attr_reader :image

    def initialize(image, local_file: false)
      @image = image
      @local_file = local_file
    end

    def inline_data
      return image unless BetterImageTag.configuration.inlining_enabled

      cache "#{CACHE_PREFIX}:#{image}" do
        svg? ? contents : "data:#{content_type};base64,#{base64_contents}"
      end
    rescue *HTTP_ERRORS
      image
    end

    private

    def cache(tag, &block)
      return unless block

      unless BetterImageTag.configuration.cache_inlining_enabled
        return block.call
      end

      Rails.cache.fetch tag, &block
    end

    def svg?
      content_type == "image/svg+xml"
    end

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
          URI.open(image).read
        elsif local_file?
          File.read(image)
        elsif not_compiled?
          Rails.application.assets[image].to_s
        else
          file = Rails.application.assets_manifest.assets[image]

          if file.nil?
            raise(
              BetterImageTag::Errors::FileNotFound,
              "Not found in asset manifest: #{image}"
            )
          end

          path = File.join(Rails.application.assets_manifest.directory, file)
          File.read(path)
        end
      end
    end
    # rubocop:enable Security/Open

    def not_compiled?
      Rails.env.development? || Rails.env.test?
    end

    def local_file?
      @local_file
    end
  end
end
