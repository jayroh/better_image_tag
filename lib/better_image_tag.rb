# frozen_string_literal: true

require 'better_image_tag/version'
require 'better_image_tag/errors'
require 'better_image_tag/picture_tag'
require 'better_image_tag/image_tag'
require 'better_image_tag/inline_data'
require 'better_image_tag/railtie' if defined?(Rails)

module BetterImageTag
  class << self
    attr_writer :configuration
  end

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.configure
    self.configuration ||= Configuration.new
    yield(configuration)
  end

  class Configuration
    attr_accessor(
      :cache_inlining_enabled,
      :cache_sizing_enabled,
      :inlining_enabled,
      :require_alt_tags,
      :images_path,
    )

    def initialize
      @require_alt_tags = false
      @cache_sizing_enabled = false
      @cache_inlining_enabled = false
      @inlining_enabled = true
      @images_path = "#{Rails.root}/app/assets/images"
    end
  end
end
