# frozen_string_literal: true

require 'rails_helper'

class BetterImageTagController < ApplicationController
  include BetterImageTag::ImageTaggable
end

RSpec.describe BetterImageTagController, type: :controller do
  before do
    BetterImageTag.configure do |config|
      config.require_alt_tags = false
    end
  end

  context 'when the concern is not included' do
    controller do
      def index
        render plain: image_tag('1x1.jpg')
      end
    end

    it 'uses the stock image tag' do
      routes.draw { get 'index' => 'better_image_tag#index' }

      get :index

      expect(response.body).to eq '<img src="/assets/1x1.jpg" />'
    end
  end

  context 'when the concern is included' do
    controller do
      include BetterImageTag::ImageTaggable

      def index
        render plain: image_tag('1x1.jpg').lazy_load
      end
    end

    it 'uses the better image tag' do
      routes.draw { get 'index' => 'better_image_tag#index' }

      get :index

      expect(response.body)
        .to start_with '<img class="lazyload" data-src="/assets/1x1.jpg"'
    end
  end

  context 'when constraining usage with an if conditional' do
    controller do
      include BetterImageTag::ImageTaggable

      better_image_tag if: :in_index?

      def index
        render plain: image_tag('1x1.jpg').lazy_load
      end

      def show
        render plain: image_tag('1x1.jpg').lazy_load
      end

      private

      def in_index?
        action_name == 'index'
      end
    end

    before do
      routes.draw do
        get 'index' => 'better_image_tag#index'
        get 'show' => 'better_image_tag#show'
      end
    end

    it 'uses the better image tag for index' do
      get :index

      expect(response.body)
        .to start_with '<img class="lazyload" data-src="/assets/1x1.jpg"'
    end

    it 'does not use the better image tag for show' do
      get :show

      expect(response.body).to eq '<img src="/assets/1x1.jpg" />'
    end
  end

  context 'when constraining usage with an unless conditional' do
    controller do
      include BetterImageTag::ImageTaggable

      better_image_tag unless: :in_index?

      def index
        render plain: image_tag('1x1.jpg').lazy_load
      end

      def show
        render plain: image_tag('1x1.jpg').lazy_load
      end

      private

      def in_index?
        action_name == 'index'
      end
    end

    before do
      routes.draw do
        get 'index' => 'better_image_tag#index'
        get 'show' => 'better_image_tag#show'
      end
    end

    it 'uses the better image tag for show' do
      get :show

      expect(response.body)
        .to start_with '<img class="lazyload" data-src="/assets/1x1.jpg"'
    end

    it 'does not use the better image tag for index' do
      get :index

      expect(response.body).to eq '<img src="/assets/1x1.jpg" />'
    end
  end
end
