namespace :test do
  desc "Prepare the database"
  task :prepare do
    prepare_postgres
    prepare_mysql
  end

  def prepare_postgres
    `dropdb auto_validate 2>&1`
    `createdb auto_validate > /dev/null`
    `psql auto_validate -f #{schema_location("postgresql")}`
  end

  def prepare_mysql
    `echo "drop database auto_validate" | mysql -uroot 2>&1`
    `echo "create database auto_validate" | mysql -uroot > /dev/null`
    `mysql -uroot auto_validate < #{schema_location("mysql")}`
  end

  def schema_location(db)
    File.join(File.dirname(__FILE__),
              "..", "..",
              "test",
              "dummy_migrations",
              "#{db}.sql")
  end

  desc "Test PostgreSQL"
  task :postgres do
    prepare_postgres
    ENV["DATABASE"] = "postgresql"
    Rake::Task["test"].invoke
  end

  desc "Test MySQL"
  task :mysql do
    prepare_mysql
    ENV["DATABASE"] = "mysql2"
    Rake::Task["test"].invoke
  end
end
