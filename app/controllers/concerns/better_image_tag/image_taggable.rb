# frozen_string_literal: true

require 'active_support/concern'

module BetterImageTag
  module ImageTaggable
    extend ::ActiveSupport::Concern

    module ClassMethods
      attr_reader :better_image_tag_options

      def better_image_tag(better_image_tag_options = {})
        @better_image_tag_options = better_image_tag_options
          .with_indifferent_access
      end
    end

    included do
      helper_method :image_tag
    end

    def image_tag(image, options = {})
      if options.delete(:use_super)
        return ActionController::Base.helpers.image_tag(image, options)
      end

      better_image_tag = better_image_tag_not_allowed? ?
        BetterImageTag::BaseImageTag.new(self, image, options) :
        BetterImageTag::ImageTag.new(self, image, options)

      if options.delete(:use_picture)
        return better_image_tag.picture_tag.to_s.html_safe
      end

      better_image_tag
    end

    private

    def better_image_tag_not_allowed?
      options = self.class.better_image_tag_options || {}

      return !send(options[:if]) if options[:if]
      return send(options[:unless]) if options[:unless]

      false
    end
  end
end
