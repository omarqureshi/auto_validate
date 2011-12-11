require "auto_validate/version"
require "active_record"

# First run for this application will be JUST PostgreSQL, just as a
# proof of concept - currently all tests are running solely against
# 9.1, though a lot of this should work for anything over 8
#
#
# Reference for this class is at
# http://www.postgresql.org/docs/current/static/catalog-pg-constraint.html
# Also - it's advisable to read up on pg_get_constraintdef()
#
# For null constraints, something like this is possible:
#
#   select pg_attribute.*
#   from pg_attribute, pg_class
#   where pg_class.oid = pg_attribute.attrelid
#     and relname = 'users' and attnum > 0 and not attisdropped;
#
# Also for null constraints, don't bother to check for primary key -
# just assume that its an auto-increment, for now.
#
# Boolean null constraints are also a bit messy, don't bother with
# them also. Instead, do a validates_inclusion_of :in => [true, false]
# instead
#
# Example output for the above query:
#
#      attname      | attnotnull | atthasdef
# ------------------+------------+-----------
#  id               | t          | t
#  email            | t          | f
#  crypted_password | t          | f
#  admin            | t          | t
#
# Indexes on the other hand are a bit more different.
#
# There are two tables that are pretty important for this, both
# pg_index and pg_indexes. What could be done would be to look at
# pg_index and try to work out the keys for the index by looking at
# indkey, however, this doesn't quite work so well for expression
# based indexes.
#
# In order to deal with those, I've ended up parsing the indexdef on
# pg_indexes. Which, although may be slower, would result in one
# database query rather than two. Eventually what could be done is one
# query with a join when the indkey is 0
#
#
# something like:
#
# select *
# from pg_index, pg_class, pg_indexes
# where pg_class.oid = pg_index.indexrelid
#   and pg_indexes.indexname = pg_class.relname
#   and pg_indexes.tablename = '#{self.table_name}'
#   and not pg_index.indisprimary
#   and pg_index.indisunique
#
# maybe?
#
# TODO:
# * Numericality checks
# * Length checks - not sure how to tackle lower bound
# * Check constraints with an in clause
# * Unique index checks without having to parse the SQL


module AutoValidate
  mattr_accessor :constraints, :indexes, :defined_primary_key
  extend ActiveSupport::Memoizable

  def auto_validate
    self.defined_primary_key = locate_primary_key
    self.constraints = load_constraints
    self.indexes = load_unique_indexes
    add_validates_presence_of_and_boolean_validations
    add_validates_uniqueness_of
    add_validates_numericality_of
  end

  private

  def load_constraints
    str = "and attname != '#{defined_primary_key}'" if defined_primary_key
    connection.execute <<EOS
select pg_attribute.*
from pg_attribute, pg_class
where pg_class.oid = pg_attribute.attrelid
  and relname = '#{self.table_name}'
  and attnum > 0
  and not attisdropped
  #{str};
EOS
  end

  def load_unique_indexes
    res = connection.execute <<EOS
select *
from pg_index, pg_class, pg_indexes
where pg_class.oid = pg_index.indexrelid
  and pg_indexes.indexname = pg_class.relname
  and pg_indexes.tablename = '#{self.table_name}'
  and not pg_index.indisprimary
  and pg_index.indisunique
EOS
    res.map {|x| x["indexdef"]}
  end

  def locate_primary_key
    connection.select_value <<EOS
select pg_attribute.attname
from pg_index, pg_class, pg_attribute
where
  pg_class.oid = '#{self.table_name}'::regclass
  and indrelid = pg_class.oid
  and pg_attribute.attrelid = pg_class.oid
  and pg_attribute.attnum = any(pg_index.indkey)
  and indisprimary
EOS
  end

  def add_validates_presence_of_and_boolean_validations
    requiring_validation = constraints.reduce({:null => [], :bool => []}) do |mem, res|
      if res["atttypid"] == boolean_type
        mem[:bool] << res
      else
        mem[:null] << res if res["attnotnull"] == 't'
      end
      mem
    end
    requiring_validation[:null].each do |res|
      self.class_eval do
        validates_presence_of res["attname"].to_sym
      end
    end
    requiring_validation[:bool].each do |res|
      self.class_eval do
        validates_inclusion_of res["attname"].to_sym, :in => [true, false]
      end
    end
  end

  def add_validates_uniqueness_of
    indexes.reduce({}) do |mem, res|
      res = res.gsub(/CREATE UNIQUE INDEX ([a-zA-Z0-9_]*) ON ([a-zA-Z0-9_]*) USING ([a-zA-Z0-9]*) \(/, "")
      res = res[0..-2]
      res = res.split(/(\(|\))/).reduce([]) do |mem, res|
        mem << res unless ["(", ")"].include?(res)
        mem
      end
      case res.size
      when 1
        add_case_sensitive_validates_uniqueness_of(res.first)
      when 2
        if res[0].downcase == "lower"
          add_case_insensitive_validates_uniqueness_of(res.last)
        end
      end
    end
  end

  def add_case_sensitive_validates_uniqueness_of(attr)
    self.class_eval do
      validates_uniqueness_of attr.to_sym
    end
  end

  def add_case_insensitive_validates_uniqueness_of(attr)
    self.class_eval do
      validates_uniqueness_of attr.to_sym, :case_sensitive => false
    end
  end

  def add_validates_numericality_of
  end

  def boolean_type
    connection.select_value <<EOS
select oid from pg_type where typname = 'bool'
EOS
  end
  memoize :boolean_type

end

class ActiveRecord::Base
  extend AutoValidate
end
