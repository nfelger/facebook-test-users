require File.expand_path('../lib/app', __FILE__)

desc "Migrate the database"
task :migrate_db do
  DataMapper.auto_migrate!
end