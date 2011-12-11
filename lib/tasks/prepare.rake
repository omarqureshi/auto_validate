namespace :test do
  desc "Prepare the database"
  task :prepare do
    `dropdb auto-validate`
    `createdb auto-validate`
    file = File.join(File.dirname(__FILE__),
                     "..", "..",
                     "test",
                     "dummy_migrations",
                     "postgresql.sql")
    `psql auto-validate -f #{file}`
  end
end
