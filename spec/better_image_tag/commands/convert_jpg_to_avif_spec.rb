# frozen_string_literal: true

require 'rails_helper'
require 'better_image_tag/commands/convert_jpg_to_avif'
require 'fileutils'

RSpec.describe BetterImageTag::Commands::ConvertJpgToAvif do
  let(:converter) { described_class.new }
  let(:asset_path) { File.expand_path('../../fixtures/assets', __dir__) }

  it 'loops through all jpg assets and creates avifs' do
    allow(converter).to receive(:asset_path).and_return(asset_path)

    expect(jpgs.count).to eq 2
    expect(avifs.count).to eq 0

    converter.call

    expect(jpgs.count).to eq 2
    expect(avifs.count).to eq 2

    delete_avifs
  end

  it 'raises error if avif is not installed' do
    allow(converter).to receive(:avif_exists?).and_return(false)

    expect { converter.call }
      .to raise_error(BetterImageTag::Errors::AvifNotFound)
  end

  def delete_avifs
    avifs.each { |avif| FileUtils.rm avif }
  end

  def jpgs
    Dir.glob "#{asset_path}/**/*.{jpg,jpeg}"
  end

  def avifs
    Dir.glob "#{asset_path}/**/*.avif"
  end
end
