# frozen_string_literal: true

require 'better_image_tag/commands/clear_inline_cache'

namespace :better_image_tag do
  desc 'Clear cached inline data'
  task :clear_inline_cache do
    BetterImageTag::Commands::ClearInlineCache.call
  end
end
