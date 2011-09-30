require 'pathname'
require 'rubygems'

gem 'addressable', '~>2.0'
gem 'rspec',       '>1.1.2'

require 'addressable/uri'
require 'spec'

SPEC_ROOT = Pathname(__FILE__).dirname.expand_path
$LOAD_PATH.unshift(SPEC_ROOT.parent + 'lib')

require 'dm-core'

ENV['PLUGINS'].to_s.strip.split(/\s+/).each do |plugin|
  require plugin
end

Pathname.glob((SPEC_ROOT + '{lib,*/shared}/**/*.rb').to_s).each { |file| require file }

# create sqlite3_fs directory if it doesn't exist
temp_db_dir = SPEC_ROOT.join('db')
temp_db_dir.mkpath

ENV['ADAPTERS'] ||= 'all'

HAS_DO = DataMapper::Adapters.const_defined?('DataObjectsAdapter')

ADAPTERS = []

PRIMARY = {
  'in_memory'  => { :adapter => :in_memory },
  'yaml'       => "yaml://#{temp_db_dir}/primary_yaml",
  'sqlite3'    => 'sqlite3::memory:',
#  'sqlite3_fs' => "sqlite3://#{temp_db_dir}/primary.db",
  'mysql'      => 'mysql://root@localhost/dm_core_test',
  'postgres'   => 'postgres://postgres@localhost/dm_core_test'
}

ALTERNATE = {
  'in_memory'  => { :adapter => :in_memory },
  'yaml'       => "yaml://#{temp_db_dir}/secondary_yaml",
  'sqlite3'    => "sqlite3://#{temp_db_dir}/alternate.db",  # use a FS for the alternate because there can only be one memory db at a time in SQLite3
#  'sqlite3_fs' => "sqlite3://#{temp_db_dir}/alternate.db",
  'mysql'      => 'mysql://root@localhost/dm_core_test2',
  'postgres'   => 'postgres://postgres@localhost/dm_core_test2'
}

# These environment variables will override the default connection string:
#   MYSQL_SPEC_URI
#   POSTGRES_SPEC_URI
#   SQLITE3_SPEC_URI
#
# For example, in the bash shell, you might use:
#   export MYSQL_SPEC_URI="mysql://localhost/dm_core_test?socket=/opt/local/var/run/mysql5/mysqld.sock"

adapters = ENV['ADAPTERS'].split(' ').map { |adapter_name| adapter_name.strip.downcase }.uniq
adapters = PRIMARY.keys if adapters.include?('all')

PRIMARY.only(*adapters).each do |name, default|
  connection_string = ENV["#{name.upcase}_SPEC_URI"] || default
  begin
    adapter = DataMapper.setup(name.to_sym, connection_string)

    # test the connection if possible
    if adapter.respond_to?(:query)
      adapter.query('SELECT 1')
    end

    ADAPTERS << name
    PRIMARY[name] = connection_string  # ensure *_SPEC_URI is saved
  rescue Exception => exception
    puts "Could not connect to the database using #{connection_string.inspect} because: #{exception.inspect}"
  end
end

ADAPTERS.freeze
PRIMARY.freeze

logger = DataMapper::Logger.new(DataMapper.root / 'log' / 'dm.log', :debug)
logger.auto_flush = true

Spec::Runner.configure do |config|
  config.extend(DataMapper::Spec::AdapterHelpers)
  config.include(DataMapper::Spec::PendingHelpers)
  config.after :all do
    # global model cleanup
    descendants = DataMapper::Model.descendants.dup.to_a
    while model = descendants.shift
      descendants.concat(model.descendants.to_a) if model.respond_to?(:descendants)

      parts         = model.name.split('::')
      constant_name = parts.pop.to_sym
      base          = parts.empty? ? Object : Object.full_const_get(parts.join('::'))

      base.send(:remove_const, constant_name)

      DataMapper::Model.descendants.delete(model)
    end
  end
end
