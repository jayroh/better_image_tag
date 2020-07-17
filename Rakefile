# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

Dir.glob('./lib/better_image_tag/tasks/*.rake').each do |rake|
  import rake
end

RSpec::Core::RakeTask.new(:spec)

task default: :spec
