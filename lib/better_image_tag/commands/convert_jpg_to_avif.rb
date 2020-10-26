# frozen_string_literal: true

module BetterImageTag
  module Commands
    class ConvertJpgToAvif
      def self.call
        new.call
      end

      def initialize
        @jpgs_converted = 0
      end

      def call
        ensure_avif_present!

        jpg_assets.each do |jpg|
          avif = jpg.gsub(/\.jpe?g\z/i, '.avif')
          next if File.exist? avif

          @jpgs_converted += 1 if system("avif -q 32 -e #{jpg} -o #{avif}")
        end

        puts "#{@jpgs_converted} jpgs converted to avif."
      end

      private

      def ensure_avif_present!
        return if avif_exists?

        raise(
          BetterImageTag::Errors::AvifNotFound,
          "'avif' not found. Please install go-avif."
        )
      end

      def avif_exists?
        `which avif`
        $CHILD_STATUS.success?
      end

      def jpg_assets
        Dir.glob "#{asset_path}/**/*.{jpg,jpeg}"
      end

      def asset_path
        BetterImageTag.configuration.images_path
      end
    end
  end
end
