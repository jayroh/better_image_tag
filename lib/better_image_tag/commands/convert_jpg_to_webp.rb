# frozen_string_literal: true

module BetterImageTag
  module Commands
    class ConvertJpgToWebp
      def self.call
        new.call
      end

      def initialize
        @jpgs_converted = 0
      end

      def call
        ensure_convert_present!

        jpg_assets.each do |jpg|
          webp = jpg.gsub(/\.jpe?g\z/i, '.webp')
          next if File.exist? webp

          @jpgs_converted += 1 if system("convert #{jpg} #{webp}")
        end

        puts "#{@jpgs_converted} jpgs converted to webp."
      end

      private

      def ensure_convert_present!
        return if convert_exists?

        raise(
          BetterImageTag::Errors::ConvertNotFound,
          "'convert' not found. Please install ImageMagick."
        )
      end

      def convert_exists?
        `which convert`
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
