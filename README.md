# BetterImageTag

`better_image_tag` is a drop-in evolution (mutation?) of Rails' stock
`image_tag` view helper. "Is that really necessary?", you might say. No, not
necessarily, but there are opportunities for improvement in the typical web
app/site work-flow that are addressable via common boilerplate code that
-- we hope -- is wrapped up nicely into this gem. Namely:

* Using webp or avif versions of an image if the browser supports it.
* A rake task that will generate webp or avif versions of all jpg's in your app.
* Ability to inline contents of an image as a base64 encoded string.
* Inlining SVG's will output the contents of the SVG image instead of using img
  tag and its base64 encoded data. This also allows for width, height, and
  class properties to be applied to the root SVG tag.
* In conjunction with the excellent [lazysizes] JS library, lazy-loading
  of images.
* Fetching dimensions of, typically, user-generated image content and
  applying width and height properties to the image tag
* An `inlineable` executable is provided for cases where you're not working
  with Rails and just need a tool to output the base64 data url for images or
  css.

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
  config.sizing_enabled         = true
  config.require_alt_tags       = false
end
```

* `cache_inlining_enabled` uses Rails' cache for the base64 encoded contents of an image path
* `cache_sizing_enabled` uses Rails' cache for the width and height dimensions of an images path/url.
* `images_path` points to the base image assets' path in your application.
* `inlining_enabled` turns the inlining mechanism on or off.
* `sizing_enabled` turns the image size fetching mechanism on or off.
* `require_alt_tags`, when set to true, will raise an exception if an image tag does not have an alt attribute set. [Adding alternative text to photos is first and foremost a principle of web accessibility]. This helps enforce usage of alt tags in an effort to increase web accessibility.

[Adding alternative text to photos is first and foremost a principle of web accessibility]: https://moz.com/learn/seo/alt-text

## Usage

Add the controller concern to the controllers where you would like to use
`better_image_tag`:

```
class HomepageController < ApplicationController
  include BetterImageTag::ImageTaggable
end
```

Optionally, you can further constrain usage with a `better_image_tag` class
method. This is useful for scenarios where you want to use the features for
one action only:

```
class HomepageController < ApplicationController
  include BetterImageTag::ImageTaggable

  better_image_tag if: :needs_better_image_tags?
  better_image_tag unless: :we_dont?
end
```

Furthermore, sometimes there are view partials shared across some controllers
that _do_ use `better_image_tag` and some that _do not_. In that case, you
would want to ensure that the endpoints/controllers pulling those partials in
will still function when the chained methods are called. In this case you can
"disable" the better_image_tag functionality explicitly in the controller that
is not using it:


```
class AnotherController < ApplicationController
  include BetterImageTag::ImageTaggable

  # explicitly pass through chained methods to default behavior
  better_image_tag disabled: true
end
```

## CLI usage

There is an `inlineable` cli that will accept the path to a local image and will
output a base64 data url that can be used in your image `src`, or css `url()`
properties.

Example:

```sh
$ inlineable ./path/to/image.jpg
data:image/jpeg;base64,/9j/4AAQSkZJRgABAQAAAQABAAD/2wCEAAkGB ... a whole lot o' letters & numbers
```

## Features

`better_image_tag`, by default, keeps the stock `image_tag` implementation
but extends it with chainable methods that will mutate the contents of
the generated `<img/>` tag. This is done purposefully to allow you to keep
things as they stand until you're ready to tackle those image-heavy corners
of your app.

Examples - chainable methods on `image_tag`:

* `#with_size` finds the size of an image by fetching as little data as needed. *Note:* If a `height` or `width` property are passed to the image tag then this will not run.

```
<%= image_tag("http://example.com/file.jpg").with_size %>

# => <img src="http://example.com/file.jpg" width="320" height="240">
```

* `#lazy_load`

```
<%= image_tag("http://example.com/file.jpg").lazy_load %>

# => <img class="lazyload" data-src="http://example.com/file.jpg" src="data:image/gif;base64,R0lGODlhAQABAAAAACH5BAEKAAEALAAAAAABAAEAAAICTAEAOw==" />
```

* `#webp`

```
<%= image_tag("http://example.com/file.jpg").webp %>

# => <picture>
       <!--[if IE 9]><video style="display: none;"><![endif]-->
       <source srcset="http://example.com/file.webp" type="image/webp">
       <!--[if IE 9]></video><![endif]-->
       <img src="http://example.com/file.jpg" />
     </picture>

# OPTIONAL -- pass url to where another WEBP is:

<%= image_tag("http://example.com/file.jpg").webp("https://some.other-cdn.com/file.webp") %>

# => <picture>
       <!--[if IE 9]><video style="display: none;"><![endif]-->
       <source srcset="https://some.other-cdn.com/file.webp" type="image/webp">
       <!--[if IE 9]></video><![endif]-->
       <img src="http://example.com/file.jpg" />
     </picture>
```

* `#avif`

```
<%= image_tag("http://example.com/file.jpg").avif %>

# => <picture>
       <!--[if IE 9]><video style="display: none;"><![endif]-->
       <source srcset="http://example.com/file.avif" type="image/avif">
       <!--[if IE 9]></video><![endif]-->
       <img src="http://example.com/file.jpg" />
     </picture>

# OPTIONAL -- pass url to where another AVIF is:

<%= image_tag("http://example.com/file.jpg").avif("https://some.other-cdn.com/file.avif") %>

# => <picture>
       <!--[if IE 9]><video style="display: none;"><![endif]-->
       <source srcset="https://some.other-cdn.com/file.avif" type="image/avif">
       <!--[if IE 9]></video><![endif]-->
       <img src="http://example.com/file.jpg" />
     </picture>
```

* `#avif` *AND* `#webp` -- use them both!

```
<%= image_tag("http://example.com/file.jpg").avif.webp %>

# => <picture>
       <!--[if IE 9]><video style="display: none;"><![endif]-->
       <source srcset="http://example.com/file.avif" type="image/avif">
       <source srcset="http://example.com/file.webp" type="image/webp">
       <!--[if IE 9]></video><![endif]-->
       <img src="http://example.com/file.jpg" />
     </picture>
```

* `#inline`

```
<%= image_tag("http://example.com/file.jpg").inline %>

# => <img src="data:image/jpg;base64...">
```

## Rake task(s)

Included in this gem are a pair of rake tasks that will find all jpg's in your project and will convert them to webp's, or avif's, if you have the appropriate tooling available on your machine.

```
bundle exec rake better_image_tag:convert_jpgs_to_webp
bundle exec rake better_image_tag:convert_jpgs_to_avif
```

For webp you will need [ImageMagick] installed. On Macs with [homebrew] you may install with `brew install imagemagick`.

For avif you will need the `go-avif` tool, which has [binaries publicly available on their GitHub releases page].

[ImageMagick]: https://imagemagick.org/index.php
[homebrew]: https://brew.sh
[binaries publicly available on their GitHub releases page]: https://github.com/Kagami/go-avif/releases

## Testing

If you use RSpec we have provided some helpers that you may add to `rails_helper.rb` that
will allow your specs to:

1. For all specs -- turn the inlining or size fetching features off.
2. For helper or view specs -- configure the `better_image_tag` functionality per test.


In `rails_helper.rb`,
add the following:

```ruby
require "better_image_tag/rspec"

RSpec.configure do |config|
  # ...
  config.include BetterImageTag::SpecHelpers
  config.include BetterImageTag::ViewSpecHelpers, type: :view
  config.include BetterImageTag::ViewSpecHelpers, type: :helper
  # ...
```

In any of your specs you may disable inlining or sizing with the following helper methods:

```ruby
disable_better_image_tag_sizing!
disable_better_image_tag_inlining!
```

In your _view_ or _helper_ spec(s) you can configure the functionality with the same
options you can pass through the controller class method. For example:

```ruby
require "rails_helper"

RSpec.describe "home/index.html.erb", type: :view do
  it "renders main partial with inlined logo image" do
    better_image_tag

    render

    expect(rendered).to render_template("shared/_header")
    # expect(rendered).to have_inlined_logo
  end

  it "renders default image tag" do
    better_image_tag disabled: true

    render

    # ... assertions here.
  end
```

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
