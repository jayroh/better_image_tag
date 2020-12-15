module BetterImageTag
  module ViewSpecHelpers
    def better_image_tag_behavior
      view.send(:extend, BetterImageTag::ImageTaggable)

      without_partial_double_verification do
        allow(view.class).
          to receive(:better_image_tag_options).
          and_return({})
        allow(view).to receive(:view_context).and_return(view)
      end
    end

    def default_image_tag_behavior
      view.send(:extend, BetterImageTag::ImageTaggable)

      without_partial_double_verification do
        allow(view.class).
          to receive(:better_image_tag_options).
          and_return({ disabled: true })
        allow(view).to receive(:view_context).and_return(view)
      end
    end
  end
end
