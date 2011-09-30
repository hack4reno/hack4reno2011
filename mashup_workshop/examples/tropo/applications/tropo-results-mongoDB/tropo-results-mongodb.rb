%w(rubygems sinatra yaml logger mongo crack json haml).each do |lib|
  require lib
end

# Open configuration for the app
APP_CONFIG = YAML.load(File.open('config/application.yml'))

# Start logger
log = Logger.new(APP_CONFIG['log_file'])
log.level = eval "Logger::#{APP_CONFIG['log_level']}"
log.info(APP_CONFIG['app_name'] + ' started @ ' + Time.now.to_s)

# Setup Mongo connection
def connect_to_mongo
  uri = URI.parse(ENV['MONGOHQ_URL'])
  conn = Mongo::Connection.from_uri(ENV['MONGOHQ_URL'])
  db = conn.db(uri.path.gsub(/^\//, ''))
  db.collection(APP_CONFIG['mongo']['collection'])
end

# Method that receives the file and sends to S3
post '/transcription_results' do
  result = request.env["rack.input"].read
  
  begin
    result = Crack::XML.parse result
  rescue
    result = Crack::JSON.parse result
  end
  
  log.debug result.inspect
  
  mongo_collection = connect_to_mongo
  mongo_collection.insert({ :transcription => result })
end

get '/transcription_results' do
  mongo_collection = connect_to_mongo
  @results = []
  mongo_collection.find.each { |row| @results << row }
  log.debug @results.inspect
  haml :transcription_results
end

get '/delete_transcription_results' do
  mongo_collection = connect_to_mongo
  mongo_collection.remove
  "Deleted Collection: #{APP_CONFIG['mongo']['collection']}"
end