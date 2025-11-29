# frozen_string_literal: true

require 'marcel'
require 'base64'
require 'net/http'
require 'uri'

module BetterImageTag
  class InlineData
    HTTP_ERRORS = [
      EOFError,
      Errno::ECONNRESET,
      Errno::EINVAL,
      Errno::ECONNREFUSED,
      Net::HTTPBadResponse,
      Net::HTTPHeaderSyntaxError,
      Net::ProtocolError,
      Net::ReadTimeout,
      Net::OpenTimeout,
      Timeout::Error,
      OpenSSL::SSL::SSLError,
      SocketError
    ].freeze

    DEFAULT_TIMEOUT = 10 # seconds

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
    rescue *HTTP_ERRORS => e
      handle_error(e)
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
      Marcel::MimeType.for(contents, name: image) || 'application/octet-stream'
    end

    def base64_contents
      Base64.strict_encode64 contents
    end

    def contents
      @_contents ||= begin
        if image.match?(%r{https?://})
          fetch_remote_content
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

    def fetch_remote_content
      uri = URI.parse(image)
      timeout = BetterImageTag.configuration.network_timeout || DEFAULT_TIMEOUT

      Net::HTTP.start(uri.host, uri.port,
                      use_ssl: uri.scheme == 'https',
                      open_timeout: timeout,
                      read_timeout: timeout,
                      ssl_timeout: timeout) do |http|
        request = Net::HTTP::Get.new(uri)
        response = http.request(request)

        unless response.is_a?(Net::HTTPSuccess)
          raise BetterImageTag::Errors::RemoteFetchError,
                "Failed to fetch #{image}: #{response.code} #{response.message}"
        end

        response.body
      end
    end

    def not_compiled?
      !!Rails.application.assets
    end

    def local_file?
      @local_file
    end

    def handle_error(error)
      callback = BetterImageTag.configuration.on_error
      callback&.call(error, image: image, operation: :inline_data)
    end
  end
end
