# frozen_string_literal: true

require 'rails_helper'
require 'better_image_tag/convert_jpg_to_webp'
require 'fileutils'

RSpec.describe BetterImageTag::ConvertJpgToWebp do
  let(:converter) { described_class.new }
  let(:asset_path) { File.expand_path('../fixtures/assets', __dir__) }

  it 'loops through all jpg assets and creates webps' do
    allow(converter).to receive(:asset_path).and_return(asset_path)

    expect(jpgs.count).to eq 2
    expect(webps.count).to eq 0

    converter.call

    expect(jpgs.count).to eq 2
    expect(webps.count).to eq 2

    delete_webps
  end

  it 'raises error if convert is not installed' do
    allow(converter).to receive(:convert_exists?).and_return(false)

    expect { converter.call }
      .to raise_error(BetterImageTag::Errors::ConvertNotFound)
  end

  def delete_webps
    webps.each { |webp| FileUtils.rm webp }
  end

  def jpgs
    Dir.glob "#{asset_path}/**/*.{jpg,jpeg}"
  end

  def webps
    Dir.glob "#{asset_path}/**/*.webp"
  end
end
