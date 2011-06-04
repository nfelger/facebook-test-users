require 'datamapper'

DataMapper.setup(:default, ENV['DATABASE_URL'] || 'sqlite3::memory:')

Dir[File.expand_path('../models', __FILE__) + '/*'].each do |filename|
  require filename
end

DataMapper.auto_migrate! unless ENV['DATABASE_URL']
DataMapper::Model.raise_on_save_failure = true
DataMapper.finalize