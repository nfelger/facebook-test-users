require 'datamapper'

DataMapper.setup(:default,
  ENV['DATABASE_URL'] || "sqlite3://#{File.expand_path('../../tmp/dev.db', __FILE__)}")

Dir[File.expand_path('../models', __FILE__) + '/*'].each do |filename|
  require filename
end

DataMapper::Model.raise_on_save_failure = true
DataMapper.finalize