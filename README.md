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

To install simply

`gem 'auto\_validate', :git =>
"git://github.com/omarqureshi/auto\_validate.git"`
