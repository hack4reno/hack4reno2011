require 'rubygems'
require 'sinatra'
require 'crack'
require 'appengine-apis/logger'
require 'dm-core'

# Set the logger
logger = AppEngine::Logger.new

# Configure DataMapper to use the App Engine datastore 
DataMapper.setup(:default, "appengine://auto")

# Create your model class
class VoxeoTranscriptions
  include DataMapper::Resource
  
  property :id, Serial
  property :guid, String
  property :identifier, String
  property :message, Text
end

get '/transcriptions' do
  # Just list all the shouts
  @transcriptions = VoxeoTranscriptions.all
  erb :index
end

get '/transcription' do
  # Just list all the shouts
  @transcription = VoxeoTranscriptions.first(:guid => params[:guid])
  erb :single
end

post '/receive_transcription' do
  logger.info env['rack.request.form_hash'].to_s
  begin 
    result = Crack::XML.parse env['rack.request.form_hash'].to_s
    logger.info 'XML Response encoded to Ruby Hash'
  rescue 
    result = Crack::JSON.parse env['rack.request.form_hash'].to_s
    logger.info 'JSON Response encoded to Ruby Hash'
  end
  logger.info result.inspect
  
  # Create a new shout and redirect back to the list.
  shout = VoxeoTranscriptions.create(:guid       => result['result']['guid'],
                                     :identifier => result['result']['identifier'],
                                     :message    => result['result']['transcription'])
end