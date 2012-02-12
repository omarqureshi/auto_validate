# Auto validation #

Automatically use PostgreSQL table constraints as model validations

Tests run on Ruby 1.9.2 using Rails 3.2.1

Currently supports the following constraints:

* NULL constraint
* Numeric fields
* Single column indexes (including lower indexes)
* Multi column indexes

## TODO: ##

### Immediate TODOs ###

* More efficient index validation
* simple check constraints in PostgreSQL
* Reduce the number of queries to get the information that is needed

### Long term TODOs ###
* Add support for MySQL

### Very long term TODOs ###
* Add support for DataMapper
* Add support for Sequel

## INSTALL ##

To install simply add the following to your Gemfile

`gem 'auto_validate', :git =>
"git://github.com/omarqureshi/auto_validate.git"`

## USAGE ##

Simply insert auto_validate in your class

<pre><code>class Foo &lt; ActiveRecord::Base
  auto_validate
end
</code></pre>

## TESTS ##

Before running tests, ensure you run `rake test:prepare` so that the
test database is created
