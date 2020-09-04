# BetterImageTag

`better_image_tag` is a drop-in evolution (mutation?) of Rails' stock
`image_tag` view helper. "Is that really necessary?", you might say. No, not
necessarily, but there are opportunities for improvement in the typical web
app/site work-flow that are addressable via common boilerplate code that
-- we hope -- is wrapped up nicely into this gem. Namely:

* Using a webp version of an image if the browser supports it.
* A rake task that will generate webp versions of all jpg's in your app.
* Ability to inline contents of an image as a base64 encoded string.
* In conjunction with the excellent [lazysizes] JS library, lazy-loading
  of images.
* Fetching dimensions of, typically, user-generated image content and
  applying width and height properties to the image tag

Everything above is in service of making web pages render faster. If you're
familiar with [Google's lighthouse page speed tool], or [WebPageTest], then
you may be familiar with some of the strategies outlined above.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'better_image_tag'
```

And then execute:

```sh
$ bundle
```

To make use of the lazy-loading, install [lazysizes] with your javascript budndler of choice -- webpacker, the asset pipeline, etc.

## Configuration

You may configure `better_image_tag` with an initializer (eg: `config/initializers/better_image_tag.rb`) containing any or all of the following:

```
# the following are the defaults

BetterImageTag.configure do |config|
  config.cache_inlining_enabled = false
  config.cache_sizing_enabled   = false
  config.images_path            = "#{Rails.root}/app/assets/images"
  config.inlining_enabled       = true
  config.require_alt_tags       = false
end
```

* `cache_inlining_enabled` uses Rails' cache for the base64 encoded contents of an image path
* `cache_sizing_enabled` uses Rails' cache for the width and height dimensions of an images path/url.
* `images_path` points to the base image assets' path in your application.
* `inlining_enabled` turns the inlining mechanism on or off.
* `require_alt_tags`, when set to true, will raise an exception if an image tag does not have an alt attribute set. [Adding alternative text to photos is first and foremost a principle of web accessibility]. This helps enforce usage of alt tags in an effort to increase web accessibility.

[Adding alternative text to photos is first and foremost a principle of web accessibility]: https://moz.com/learn/seo/alt-text

## Usage

`better_image_tag`, by default, keeps the stock `image_tag` implementation
but extends it with chainable methods that will mutate the contents of
the generated `<img/>` tag. This is done purposefully to allow you to keep
things as they stand until you're ready to tackle those image-heavy corners
of your app.

Examples - chainable methods on `image_tag`:

* `#with_size` finds the size of an image by fetching as little data as needed. *Note:* If a `height` or `width` property are passed to the image tag then this will not run.

```
<%= image_tag("http://example.com/file.jpg").with_size %>

# => <img src="http://example.com/file.jpg" width="320" height="240" >
```

* `#lazy_load`

```
<%= image_tag("http://example.com/file.jpg").with_size %>

# => <img src="http://example.com/file.jpg" width="320" height="240" >
```

* `#webp`

```
<%= image_tag("http://example.com/file.jpg").webp %>

# => <img src="http://example.com/file.webp" width="320" height="240" >
```

* `#inline`

```
<%= image_tag("http://example.com/file.jpg").inline %>

# => <img src="data:image/jpg;base64...">
```

## Rake task(s)

TODO

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/jayroh/better_image_tag. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the BetterImageTag project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/jayroh/better_image_tag/blob/master/CODE_OF_CONDUCT.md).

[Google's lighthouse page speed tool]: https://developers.google.com/web/tools/lighthouse
[WebPageTest]: https://webpagetest.org
[lazysizes]: https://github.com/aFarkas/lazysizes
