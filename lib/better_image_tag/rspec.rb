module BetterImageTag
  module SpecHelpers
    def disable_better_image_tag_sizing!
      BetterImageTag.configuration.sizing_enabled = false
    end

    def disable_better_image_tag_inlining!
      BetterImageTag.configuration.inlining_enabled = false
    end
  end

  module ViewSpecHelpers
    def better_image_tag(options = {})
      view.send(:extend, BetterImageTag::ImageTaggable)

      without_partial_double_verification do
        allow(view.class).
          to receive(:better_image_tag_options).
          and_return(options)
        allow(view).to receive(:view_context).and_return(view)
      end
    end
  end
end
