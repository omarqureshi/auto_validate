require "auto_validate/version"
require "active_record"

# First run for this application will be JUST PostgreSQL, just as a
# proof of concept - currently all tests are running solely against
# 9.1, though a lot of this should work for anything over 8
#
# Reference for this class is at
# http://www.postgresql.org/docs/current/static/catalog-pg-constraint.html
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
# * Check constraints with an in clause
# * Unique index checks without having to parse the SQL
# * Figure out how to reuse the pg_attr query that ActiveRecord uses
# in Rails 3.0+ or indeed modify it so that there are less table
# introspection queries to be done.


module AutoValidate
  mattr_accessor :attributes, :indexes, :defined_primary_key

  def auto_validate
    if connection.table_exists?(table_name)
      self.defined_primary_key = locate_primary_key
      self.attributes = load_attributes
      self.indexes = load_unique_indexes
      add_validates_presence_of_and_boolean_validations
      add_validates_uniqueness_of
      add_validates_numericality_of
    end
  end

  private

  def load_attributes
    str = "and attname != '#{defined_primary_key}'" if defined_primary_key
    timestamps = "and attname != 'created_at'
                  and attname != 'updated_at'
                  and attname != 'created_on'
                  and attname != 'updated_on'"
    connection.execute <<EOS
select pg_attribute.*, typcategory
from pg_attribute, pg_class, pg_type
where pg_class.oid = pg_attribute.attrelid
  and pg_type.oid = pg_attribute.atttypid
  and relname = '#{self.table_name}'
  and attnum > 0
  and not attisdropped
  #{str}
  #{timestamps};
EOS
  end

  def load_unique_indexes
    # alternatively - fetch all indexes in a single query?
    res = connection.select_values <<EOS
select indexdef
from pg_index, pg_class, pg_indexes
where pg_class.oid = pg_index.indexrelid
  and pg_indexes.indexname = pg_class.relname
  and pg_indexes.tablename = '#{self.table_name}'
  and not pg_index.indisprimary
  and pg_index.indisunique
EOS
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
    attributes.each do |res|
      if res["atttypid"] == boolean_type
        self.class_eval do
          validates_inclusion_of res["attname"].to_sym, :in => [true, false]
        end
      else
        if res["attnotnull"] == 't' && res["atthasdef"] == 'f'
          self.class_eval do
            validates_presence_of res["attname"].to_sym
          end
        end
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
    index = multicolumn_index(attr)
    scope = index[1..-1]
    self.class_eval do
      if scope.empty?
        validates_uniqueness_of index[0].to_sym
      else
        validates_uniqueness_of index[0].to_sym, :scope => scope
      end
    end
  end

  def add_case_insensitive_validates_uniqueness_of(attr)
    index = multicolumn_index(attr)
    scope = index[1..-1]
    self.class_eval do
      if scope.empty?
        validates_uniqueness_of attr.to_sym, :case_sensitive => false
      else
        validates_uniqueness_of attr.to_sym, :case_sensitive => false, :scope => scope
      end
    end
  end

  def multicolumn_index(attr)
    attr.split(",").map(&:strip)
  end

  def add_validates_numericality_of
    attributes.each do |attribute|
      if attribute["typcategory"] == "N"
        # convert attlen to number bit count, use as power of 2 and
        # divide by 2 to take into account negativity - 1
        # i.e. for integer (attlen 4)
        # this becomes 2 ** (4*8) then divide by 2 and -1 so that the
        # range of -2147483648 to +2147483647 is captured
        maxsize = ((2 ** (attribute["attlen"].to_i * 8)) / 2) - 1
        minsize = 0-maxsize-1
        self.class_eval do
          validates_numericality_of attribute["attname"].to_sym, :less_than => maxsize, :greater_than => minsize
        end
      end
    end
  end

  def boolean_type
    unless defined? @_boolean_type
      @_boolean_type = connection.select_value <<EOS
select oid from pg_type where typname = 'bool'
EOS
    end
  end

end

class ActiveRecord::Base
  extend AutoValidate
end
