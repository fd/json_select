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

JSONSelect('string:first-child').test(json)    # => true
JSONSelect('string:first-child').match(json)   # => "window"
JSONSelect('string:first-child').matches(json) # => ["window", "beer"]
```

## Language support

✓ — **Level 1** — `*`<br>
Any node

✓ — **Level 1** — `T`<br>
A node of type `T`, where `T` is one `string`, `number`, `object`, `array`, `boolean`, or `null`

✓ — **Level 1** — `T.key`<br>
A node of type `T` which is the child of an object and is the value its parents key property

✓ — **Level 1** — `T."complex key"`<br>
Same as previous, but with property name specified as a JSON string

✓ — **Level 1** — `T:root`<br>
A node of type `T` which is the root of the JSON document

✓ — **Level 1** — `T:nth-child(n)`<br>
A node of type `T` which is the nth child of an array parent

✓ — **Level 2** — `T:nth-last-child(n)`<br>
A node of type `T` which is the nth child of an array parent counting from the end

✓ — **Level 1** — `T:first-child`<br>
A node of type `T` which is the first child of an array parent (equivalent to `T:nth-child(1)`)

✓ — **Level 2** — `T:last-child`<br>
A node of type `T` which is the last child of an array parent (equivalent to `T:nth-last-child(1)`)

✓ — **Level 2** — `T:only-child`<br>
A node of type `T` which is the only child of an array parent

✓ — **Level 2** — `T:empty`<br>
A node of type `T` which is an array or object with no child

✓ — **Level 1** — `T U`<br>
A node of type `U` with an ancestor of type `T`

✓ — **Level 1** — `T > U`<br>
A node of type `U` with a parent of type `T`

✗ — **Level 2** — `T ~ U`<br>
A node of type `U` with a sibling of type `T`

✓ — **Level 1** — `S1, S2`<br>
Any node which matches either selector `S1` or `S2`

✗ — **Level 3** — `T:has(S)`<br>
A node of type `T` which has a child node satisfying the selector `S`


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