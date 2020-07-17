# frozen_string_literal: true

require 'spec_helper'
require 'vcr'
ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('dummy/config/environment.rb', __dir__)

if Rails.env.production?
  abort('The Rails environment is running in production mode!')
end

require 'rspec/rails'

RSpec.configure do |config|
  config.infer_spec_type_from_file_location!

  config.filter_rails_from_backtrace!
end

VCR.configure do |config|
  config.hook_into :webmock
  config.ignore_hosts '127.0.0.1', 'localhost'
  config.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
end
