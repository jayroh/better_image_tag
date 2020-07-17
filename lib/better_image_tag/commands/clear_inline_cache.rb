# frozen_string_literal: true

module BetterImageTag
  module Commands
    class ClearInlineCache
      def self.call
        new.call
      end

      def call
        inline_cache_keys.select do |key|
          Rails.cache.delete key
        end
      end

      private

      def inline_cache_keys
        cache_keys.select do |key|
          key.start_with? BetterImageTag::InlineData::CACHE_PREFIX
        end
      end

      def cache_keys
        Rails.cache.instance_variable_get(:@data)&.keys || []
      end
    end
  end
end
