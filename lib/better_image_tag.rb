# frozen_string_literal: true
require "better_image_tag/version"
require "better_image_tag/errors"
require "better_image_tag/image_tag"
require "better_image_tag/inline_data"

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
      :cache_enabled,
      :inlining_enabled,
      :require_alt_tags
    )

    def initialize
      @require_alt_tags = false
      @cache_enabled = false
      @inlining_enabled = true
    end
  end
end
