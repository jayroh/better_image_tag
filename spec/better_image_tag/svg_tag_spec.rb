# frozen_string_literal: true

require 'spec_helper'

RSpec.describe BetterImageTag::SvgTag do
  describe '#to_s' do
    it 'adds data attributes to the tag' do
      image_tag = OpenStruct.new(
        image: '<svg xmlns="http://www.w3.org/2000/svg"></svg>',
        options: {
          data: {
            custom_key: 'value',
            another_key: 'another value'
          }
        }
      )

      svg = described_class.new(image_tag)
      expected = '<svg data-custom-key="value" data-another-key="another value" xmlns="http://www.w3.org/2000/svg"></svg>'

      expect(svg.to_s).to eq expected
    end
  end
end
