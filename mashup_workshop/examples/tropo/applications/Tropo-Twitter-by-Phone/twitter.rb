%w(rubygems sinatra tropo-webapi-ruby pp open-uri rexml/document goodies.rb).each{|lib| require lib}
require File.dirname(__FILE__) + '/vendor/gems/environment'
Bundler.require_env

enable :sessions

post '/index.json' do
  v = Tropo::Generator.parse request.env["rack.input"].read
  session[:id] = v[:session][:id]
  session[:caller] = v[:session][:from]
  session[:user] = "voxeo"
  session[:page] = 1  # This shouldn't be tinkered with unless you don't want the most recent tweets to be heard.
  t = Tropo::Generator.new
    t.on :event => 'continue', :next => '/process.json'
    t.on :event => 'error', :next => '/error.json'     # For fatal programming errors. Log some details so we can fix it
    t.on :event => 'hangup', :next => '/hangup.json'   # When a user hangs or call is done. We will want to log some details.
    t.on :event => 'incomplete', :next => '/incomplete.json'
    t.say "You have reached @#{session[:user]}'s tweets-by-phone."

    t.ask :name => 'count', :bargein => true, :timeout => 7, :required => true, :attempts => 4,
        :say => [{:event => "timeout", :value => "Sorry, I did not hear anything."},
                 {:event => "nomatch:1 nomatch:2 nomatch:3", :value => "That wasn't a one digit number."},
                 {:value => "How many tweets do you want to listen to at once? Enter or say a one digit number."},
                 {:event => "nomatch:3", :value => "This is your last attempt. Watch it."}],
                  :choices => { :value => "[1 DIGITS]"}
  t.response
end

# NOTE, This incomplete event is not necessary.
#       To be more user friendly, you can simply not define an incomplete action and
#       validate input with Ruby logic inside the 'continue' event's document.
post '/incomplete.json' do
  v = Tropo::Generator.parse request.env["rack.input"].read
  t = Tropo::Generator.new
    t.on  :event => 'error', :next => '/error.json'     # For fatal programming errors. Log some details so we can fix it
    t.on  :event => 'hangup', :next => '/hangup.json'   # When a user hangs or call is done. We will want to log some details.
    t.say "You failed to enter a valid number #{v[:result][:actions][:attempts]} times."
    t.say "Please call back and try again or contact us for help."
    t.hangup
  t.response
end

post '/process.json' do
  v = Tropo::Generator.parse request.env["rack.input"].read
  t = Tropo::Generator.new
    t.on  :event => 'error', :next => '/error.json'     # For fatal programming errors. Log some details so we can fix it
    t.on  :event => 'hangup', :next => '/hangup.json'   # When a user hangs or call is done. We will want to log some details.
    t.on  :event => 'continue', :next => '/say_page_of_tweets.json'
    session[:count] = v[:result][:actions][:count][:value]
    # t.say "@#{session[:user]} tweets coming right up!"
  t.response  
end

post '/say_page_of_tweets.json' do
  t = Tropo::Generator.new
    t.on  :event => 'error', :next => '/error.json'     # For fatal programming errors. Log some details so we can fix it
    t.on  :event => 'hangup', :next => '/hangup.json'   # When a user hangs or call is done. We will want to log some details.
    t.on  :event => 'continue', :next => '/say_page_of_tweets.json'
    t.say "I'm about to read you the"
    t.say say_as_ordinal(session[:page])
    t.say " #{session[:count]} tweets by #{session[:user]}."
    source = "http://twitter.com/statuses/user_timeline/#{session[:user]}.rss?count=#{session[:count]}&page=#{session[:page]}"
    rss = REXML::Document.new(open(source).read).root
    rss.root.elements.each("channel/item") { |element|
      t.say "Tweet from about #{Time.parse(element.get_text('pubDate').to_s).to_pretty}"
      t.say reformat_uris(element.get_text('title').to_s) + "," # comma for extra pause between tweets.
    }
    session[:page] += 1
  t.response
end

post '/hangup.json' do
  v = Tropo::Generator.parse request.env["rack.input"].read
  if v[:result][:complete]
    puts "Call complete. Call duration: #{v[:result][:sessionDuration]} second(s)"
  else
    puts "/!\\ Caller hung up. Call duration: #{v[:result][:sessionDuration]} second(s)."
  end
  puts "    Caller info: ID=#{session[:caller][:id]}, Name=#{session[:caller][:name]}"
  puts "    Call logged in CDR. Tropo session ID: #{session[:id]}"
end

post '/error.json' do
  v = Tropo::Generator.parse request.env["rack.input"].read
  puts "!"*10 + "ERROR (see rack.input below); call ended"
  pp v # Print the JSON to our Sinatra console/log so we can find the error
end