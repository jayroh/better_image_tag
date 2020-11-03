# frozen_string_literal: true

require 'better_image_tag/commands/convert_jpg_to_webp'
require 'better_image_tag/commands/convert_jpg_to_avif'

namespace :better_image_tag do
  desc 'Convert jpgs to webp'
  task :convert_jpgs_to_webp do
    BetterImageTag::Commands::ConvertJpgToWebp.call
  end

  desc 'Convert jpgs to avif'
  task :convert_jpgs_to_avif do
    BetterImageTag::Commands::ConvertJpgToAvif.call
  end
end
