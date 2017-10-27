# RelationToStruct

[![Build Status](https://semaphoreci.com/api/v1/jcoleman/relation_to_struct/branches/master/badge.svg)](https://semaphoreci.com/jcoleman/relation_to_struct)

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

## Examples

You can query either via direct SQL or from an ActiveRecord relation.

### From an existing relation

```
UserPostsSummary = Struct.new(:user_name, :post_count)
relation = User.joins(:blog_posts).where(name: 'Hayek').group('users.id').select('users.name, COUNT(blog_posts.id)')
relation.to_structs(UserPostsSummary) # => array of structs
```

### From raw SQL

```
UserPostsSummary = Struct.new(:user_name, :post_count)
sql = <<-eos
  SELECT users.name, COUNT(blog_posts.id)
  FROM users
  LEFT OUTER JOIN blog_posts ON blog_posts.user_id = users.id
  GROUP BY users.id
eos

ActiveRecord::Base.structs_from_sql(UserPostsSummary, sql) # => array of structs
ActiveRecord::Base.pluck_from_sql(sql) # => array of tuples
```

```
sql = <<-eos
  SELECT users.name
  FROM users
  LIMIT 1
eos

ActiveRecord::Base.value_from_sql(sql) # => single value
```

```
sql = <<-eos
  SELECT users.id, users.name
  FROM users
  LIMIT 1
eos

ActiveRecord::Base.tuple_from_sql(sql) # => [id, name]
```

## Contributing

1. Fork it ( https://github.com/jcoleman/relation_to_struct/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Test your changes (`bundle install && appraisal install && rake`)
4. Commit your changes (`git commit -am 'Add some feature'`)
5. Push to the branch (`git push origin my-new-feature`)
6. Create a new Pull Request
