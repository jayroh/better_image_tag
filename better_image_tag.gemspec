# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'better_image_tag/version'

Gem::Specification.new do |spec|
  spec.name          = 'better_image_tag'
  spec.version       = BetterImageTag::VERSION
  spec.authors       = ['Joel Oliveira']
  spec.email         = ['joel.oliveira@ezcater.com']

  spec.summary       = 'A more robust and optimized rails image_tag'
  spec.description   = <<~EODESC
    From lazy loading, to inline image contents, to fetching unknown width and
    height, to next generation image formats, this gem aims to extend the
    default image_tag method to do more for static web pages.
  EODESC
  spec.homepage      = 'https://www.ezcater.com'
  spec.license       = 'MIT'

  # Specify which files should be added to the gem when it is released.  The
  # `git ls-files -z` loads the files in the RubyGem that have been added into
  # git.
  spec.files         = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      f.match(%r{^(test|spec|features)/})
    end
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'fastimage'
  spec.add_dependency 'mimemagic'
  spec.add_dependency 'rails'

  spec.add_development_dependency 'bundler', '~> 2.1'
  spec.add_development_dependency 'pry-byebug'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec-rails'
  spec.add_development_dependency 'vcr'
  spec.add_development_dependency 'webmock'
end
