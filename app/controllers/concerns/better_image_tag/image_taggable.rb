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
      return ActionController::Base.helpers.image_tag(image, options) if options.delete(:use_super)

      better_image_tag = if better_image_tag_allowed?
                           BetterImageTag::ImageTag.new(view_context, image, options)
                         else
                           BetterImageTag::BaseImageTag.new(view_context, image, options)
                         end

      return better_image_tag.picture_tag.to_s if options.delete(:use_picture)

      better_image_tag
    end

    private

    def better_image_tag_allowed?
      options = self.class.better_image_tag_options || {}

      return send(options[:if]) if options[:if].present?
      return !send(options[:unless]) if options[:unless].present?
      return !options[:disabled] if options[:disabled].present?

      true
    end
  end
end
