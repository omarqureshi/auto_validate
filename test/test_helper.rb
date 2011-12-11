require 'active_record'
require 'active_support'
require 'test/unit'
require 'factory_girl'
require 'connection'
require 'auto_validate'
require 'database_cleaner'

DatabaseCleaner.strategy = :truncation

%w(dummy_models factories).each do |dir|
  $LOAD_PATH.unshift("test/#{dir}")
  Dir[File.join('test', dir, '*.rb')].each do |file|
    require File.basename(file, ".rb")
  end
end

class Test::Unit::TestCase

  def setup
    DatabaseCleaner.start
  end

  def deny(condition)
    assert ! condition
  end

  def teardown
    DatabaseCleaner.clean
  end

end
