# frozen_string_literal: true

require 'better_image_tag'
require 'rails'

module BetterImageTag
  class Railtie < Rails::Railtie
    railtie_name :better_image_tag

    rake_tasks do
      path = File.expand_path(__dir__)
      Dir.glob("#{path}/tasks/**/*.rake").each { |f| load f }
    end
  end
end
