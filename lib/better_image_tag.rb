# frozen_string_literal: true
require "better_image_tag/version"
require "better_image_tag/errors"
require "better_image_tag/image_tag"
require "better_image_tag/inline_data"

module BetterImageTag
  class << self
    attr_accessor :configuration
  end

  def self.configure
    self.configuration ||= Configuration.new
    yield(configuration)
  end

  class Configuration
    attr_accessor :require_alt_tags, :cache_enabled

    def initialize
      @require_alt_tags = false
      @cache_enabled = false
    end
  end
end
