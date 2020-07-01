# frozen_string_literal: true

module BetterImageTag
  module Errors
    class Error < StandardError; end

    class MissingAltTag < Error; end
  end
end
