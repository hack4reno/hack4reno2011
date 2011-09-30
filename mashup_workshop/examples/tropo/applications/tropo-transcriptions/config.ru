require 'appengine-rack'
AppEngine::Rack.configure_app(
  :application => 'tropo-transcriptions',
  :version => 1)
require 'tropo-transcriptions'
run Sinatra::Application