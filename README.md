# chrysalis-router

[![Build Status](https://travis-ci.org/idchlife/chrysalis-router.svg?branch=master)](https://travis-ci.org/idchlife/chrysalis-router)

Chrysalis router is a simple router that just "finds route, gives you something you attached to it".
It can be anything with the type provided. String, Int, block, whatewer you want.

Router was created to work only with paths(urls). No methods, no middleware.
Search - not found - exception. Found - you get an attachment.

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  chrysalis-router:
    github: idchlife/chrysalis-router
```

## Usage

```crystal
require "chrysalis-router"

include Chrysalis::Router

# First, create an instance of manager with your type. Your type exactly
# would be the returned attachment, if route found.
manager = RoutesManager(YourType).new

# Add route with attachment to it
manager.add_route "/fleeb", YourType

# You can also add types with :variables
# This route will be found with "/fleeb/56/plumbus" or "/fleeb/juice/plumbus"
manager.add_route "/fleeb/:id/plumbus", YourType

# Then get attachment when you got path. Mind rescuing exception! Router
# raises an exception if no route found! It was made like this so you can
# make that nil can be also an attachment

begin
  attachment : YourType = manager.resolve_path "/fleeb"
rescue RouteNotFoundException
  raise "Whoops 404 guys"
end

# You can also debug structure of tree of routes by doing this
puts manager.debug_tree_structure
```

Note: trailing slashes are not seekable. Only paths without them will be found

## Development

Issues, tests and ideas are welcome!
Keep in mind - this router is made to be simple part of something larger.

## Contributing

1. Fork it ( https://github.com/idchlife/chrysalis-router/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [idchlife](https://github.com/idchlife) idchlife - creator, maintainer
