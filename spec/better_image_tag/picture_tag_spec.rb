# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BetterImageTag::PictureTag do
  let(:view_context) do
    view_paths = ActionController::Base.view_paths
    lookup_context = ActionView::LookupContext.new(view_paths)
    ActionView::Base.new(lookup_context, {})
  end

  before do
    BetterImageTag.configure do |config|
      config.require_alt_tags = false
    end
  end

  it 'adds the class from the image tag to <picture>' do
    image_tag = BetterImageTag::ImageTag.new(
      view_context,
      '1x1.jpg',
      class: 'my-class'
    )
    default_image_tag = '<img src="1x1.jpg">'
    picture_tag = described_class.new(image_tag, default_image_tag)

    expect(picture_tag.to_s).to include '<picture class="my-class--picture"'
  end
end
