# RelationToStruct

When one needs to use ActiveRecord to fetch specific values (whether subset columns of a model or arbitrary calculated columns), it's desirable to avoid the overhead of model instances and any associated callbacks.

ActiveRecord::Relation#pluck solves a similar problem but returns tuples; I wanted to be able to return Ruby structs to benefit from named instance methods.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'relation_to_struct'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install relation_to_struct

## Usage

TODO: Write usage instructions here

## Contributing

1. Fork it ( https://github.com/jcoleman/relation_to_struct/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
