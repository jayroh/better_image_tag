# frozen_string_literal: true

require 'better_image_tag/version'
require 'better_image_tag/errors'
require 'better_image_tag/picture_tag'
require 'better_image_tag/svg_tag'
require 'better_image_tag/image_tag'
require 'better_image_tag/base_image_tag'
require 'better_image_tag/inline_data'
require_relative '../app/controllers/concerns/better_image_tag/image_taggable'
require 'better_image_tag/railtie' if Object.const_defined?(:Rails)

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
      :sizing_enabled,
      :images_path
    )

    def initialize
      @require_alt_tags = false
      @cache_sizing_enabled = false
      @cache_inlining_enabled = false
      @inlining_enabled = true
      @sizing_enabled = true
      @images_path = "#{rails_root}/app/assets/images"
    end

    private

    def rails_root
      Object.const_defined?(:Rails) ? Rails.root : '.'
    end
  end
end
