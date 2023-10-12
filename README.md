# RelationToStruct

[![Build Status](https://github.com/jcoleman/relation_to_struct/actions/workflows/ci.yml/badge.svg)](https://github.com/jcoleman/relation_to_struct/actions/workflows/ci.yml?query=branch%3Amaster+)

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

Note: In order to provide a consistent user experience regardless of the abstraction level used by your code, all of the following methods are available on both `ActiveRecord::Base` and `ActiveRecord::Base.connection`.

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

```
sql = <<-eos
  SELECT 1
eos

ActiveRecord::Base.run_sql(sql) # => <no defined result>
```

```
sql = <<-eos
  INSERT INTO foos(bar) VALUES(1)
eos

ActiveRecord::Base.run_sql(sql) # => <number of rows modified>
```

## Project Policy/Philosophy

Executing database queries should be clearly explicit in your application code. Implicit queries (e.g., in association accesses) is an anti-pattern that results in problems like N+1 querying.

### Query Caching

Query caching is another problem downstream from implicit querying. Because queries are happening "behind the scenes" and there's no obvious place for explicit result caching, it seems desirable to cache at the query level. But this approach applies caching at the wrong level: your application code must still expend all of the effort required to build a SQL query and (potentially) interpret results. Caching queries automatically (as Rails does by default in a web request) can easily lead to gotchas because the framework has no way of determining when caching is actually safe (both from a business logic and query contents perspective).

For this reason, **all methods added to `ActiveRecord::Base` explicitly disable query caching**. Rails defaults are respected, however, on extensions to `ActiveRecord::Relation` since it's not as obvious that those queries are intended to be explicit.

## Contributing

1. Fork it ( https://github.com/jcoleman/relation_to_struct/fork )
1. Create your feature branch (`git checkout -b my-new-feature`)
1. Install gems and spin up a PostgreSQL container (`bin/setup`)
1. Test your changes (`bundle exec appraisal rake && DATABASE=postgresql bundle exec appraisal rake`)
1. Commit your changes (`git commit -am 'Add some feature'`)
1. Push to the branch (`git push origin my-new-feature`)
1. Create a new Pull Request

## Releasing

1. Bump version in `lib/relation_to_struct/version.rb` and commit.
1. Run `rake build` to build the `*.gem` file.
1. Run `rake release` to publish the gem to Rubygems. Note: if while releasing the gem you get the error ``Your rubygems.org credentials aren't set. Run `gem push` to set them.`` you can more simply run `gem signin`.
