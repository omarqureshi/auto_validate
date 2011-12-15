# Auto validation #

Automatically use PostgreSQL table constraints as model validations

Currently supports the following constraints:

* NULL constraint
* Numeric fields
* Single column indexes (including lower indexes)

## TODO: ##

* Multi column indexes
* More efficient index validation
* Reduce the number of queries to get the information that is needed

## INSTALL ##

To install simply add the following to your Gemfile

`gem 'auto_validate', :git =>
"git://github.com/omarqureshi/auto_validate.git"`

## USAGE ##

Simply insert auto_validate in your class

<pre><code>
class Foo &lt; ActiveRecord::Base
  auto_validate
end
</code></pre>
