# frozen_string_literal: true

require 'better_image_tag/convert_jpg_to_webp'

namespace :better_image_tag do
  desc 'Convert jpgs to webp'
  task :convert_jpgs do
    BetterImageTag::ConvertJpgToWebp.call
  end
end
