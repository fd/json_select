# JSONSelect [![Build Status](http://travis-ci.org/fd/json_select.png)](http://travis-ci.org/fd/json_select)

**CSS-like selectors for JSON.**

[More info about the JSON:select format](http://jsonselect.org/)

## Installation

From your terminal:

```bash
gem install json_select
```

In your `Gemfile`:

```ruby
gem 'json_select'
```

## Usage

```ruby
require 'json_select'

json = { # This would normally be loaded with something like yajl-ruby
  "name" => {
    "first" => "Lloyd",
    "last" => "Hilaiel"
  },
  "favoriteColor" => "yellow",
  "languagesSpoken" => [
    {
      "language" => "Bulgarian",
      "level" => "advanced"
    },
    {
      "language" => "English",
      "level" => "native"
    },
    {
      "language" => "Spanish",
      "level" => "beginner"
    }
  ],
  "seatingPreference" => [ "window", "aisle" ],
  "drinkPreference" => [ "beer", "whiskey", "wine" ],
  "weight" => 172
}

JSONSelect('string:first-child').match(json) # => ["Lloyd", "Bulgarian", "English", "Spanish", "window", "beer"]
```

## Note on Patches/Pull Requests
 
* Fork the project.
* Make your feature addition or bug fix.
* Add tests for it. This is important so I don't break it in a future version
  unintentionally.
* Commit, do not mess with `Rakefile` or version. (if you want to have your
  own version, that is fine but bump version in a commit by itself I can
  ignore when I pull)
* Send me a pull request. Bonus points for topic branches.

## Copyright

Copyright (c) 2011 Simon Menke. See LICENSE for details.