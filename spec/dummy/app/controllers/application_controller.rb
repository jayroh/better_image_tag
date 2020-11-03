# frozen_string_literal: true

class ApplicationController < ActionController::Base
  delegate :image_tag, :image_path, to: :view_helpers

  def view_helpers
    ActionController::Base.helpers
  end
end
