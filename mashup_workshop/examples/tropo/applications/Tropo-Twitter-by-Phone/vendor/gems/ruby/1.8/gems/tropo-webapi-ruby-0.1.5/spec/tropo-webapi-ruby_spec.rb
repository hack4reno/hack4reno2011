require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Tropo" do
  
  # Ask action tests (and alias Prompt)
  it "should generate a complete 'ask' JSON document" do
    response = Tropo::Generator.ask({ :name    => 'foo', 
                                      :bargein => 'true', 
                                      :timeout => 30,
                                      :require => 'true' })
    JSON.parse(response).should == { "tropo" => [{ "ask" => { "name" => "foo", "bargein" => "true", "timeout" => 30, "require" => "true" } }] }
  end
  
  it "should generate an 'ask' JSON document when a block is passed" do
    response = Tropo::Generator.ask({ :name    => 'foo', 
                                      :bargein => 'true', 
                                      :timeout => 30,
                                      :require => 'true' }) do
                                         say     :value => 'Please say your account number'
                                         choices :value => '[5 DIGITS]'
                                      end
    JSON.parse(response).should == {"tropo"=>[{"ask"=>{"name"=>"foo", "say"=>[{"value"=>"Please say your account number"}], "bargein"=>"true", "timeout"=>30, "require"=>"true", "choices"=>{"value"=>"[5 DIGITS]"}}}]}
  end

  # There is currently a feature request to support an on within an ask
  #
  # it "should generate an 'ask' JSON document when a block is passed with an 'on' action" do
  #   response = Tropo::Generator.ask({ :name    => 'foo', 
  #                                     :bargein => 'true', 
  #                                     :timeout => 30,
  #                                     :require => 'true' }) do
  #                                        say     :value => 'Please say your account number'
  #                                        choices :value => '[5 DIGITS]'
  #                                        on :event => 'success', :next => '/result.json'
  #                                     end
  #   JSON.parse(response).should == {"tropo"=>[{"ask"=>{"name"=>"foo", "say"=>[{"value"=>"Please say your account number"}], "bargein"=>"true", "timeout"=>30, "require"=>"true", "on"=>[{"event"=>"success", "next"=>"/result.json"}], "choices"=>{"value"=>"[5 DIGITS]"}}}]}
  # end
  
  it "should generate an error if an 'ask' is passed without a 'name' parameter" do
    begin
      response = Tropo::Generator.ask({ :foo => 'bar' })
    rescue => err
      err.to_s.should == "A 'name' must be provided to a 'ask' action"
    end
  end
  
  # Prompt
  it "should generate a complete 'prompt' JSON document" do
    response = Tropo::Generator.prompt({ :name    => 'foo', 
                                         :bargein => 'true', 
                                         :timeout => 30,
                                         :require => 'true' })
    JSON.parse(response).should == { "tropo" => [{ "ask" => { "name" => "foo", "bargein" => "true", "timeout" => 30, "require" => "true" } }] }
  end
  
  it "should generate an 'prompt' JSON document when a block is passed" do
    response = Tropo::Generator.prompt({ :name    => 'foo', 
                                         :bargein => 'true', 
                                         :timeout => 30,
                                         :require => 'true' }) do
                                           say     :value => 'Please say your account number'
                                           choices :value => '[5 DIGITS]'
                                         end
    JSON.parse(response).should == {"tropo"=>[{"ask"=>{"name"=>"foo", "say"=>[{"value"=>"Please say your account number"}], "bargein"=>"true", "timeout"=>30, "require"=>"true", "choices"=>{"value"=>"[5 DIGITS]"}}}]}
  end
  
  it "should generate an error if an 'prompt' is passed without a 'name' parameter" do
    begin
      response = Tropo::Generator.prompt({ :foo => 'bar' })
    rescue => err
      err.to_s.should == "A 'name' must be provided to a 'ask' action"
    end
  end
  
  # Choices tests
  it "should generate a standard 'choices' JSON document" do
    response = Tropo::Generator.choices({ :value => '[5 DIGITS]' })
    JSON.parse(response).should == { 'tropo' => [{ 'choices' => { 'value' => '[5 DIGITS]' } }] }
  end
  
  it "should raise an error if a 'choices' passes an unspported mode" do
    begin
      response = Tropo::Generator.choices({ :value => '[5 DIGITS]', :mode => 'frootloops' })
    rescue => err
      err.to_s.should == "If mode is provided, only 'dtmf', 'speech' or 'any' is supported"
    end
  end
  
  it "should generate a standard 'choices' JSON document with a mode" do
    response = Tropo::Generator.choices({ :value => '[5 DIGITS]', :mode => 'dtmf' })
    JSON.parse(response).should == { 'tropo' => [{ 'choices' => { 'value' => '[5 DIGITS]', 'mode' => 'dtmf' } }] }
  end
  
  # Conference action tests
  it "should generate a complete 'conference' JSON document" do
    response = Tropo::Generator.conference({ :name       => 'foo', 
                                             :id         => '1234', 
                                             :mute       => false,
                                             :send_tones => false,
                                             :exit_tone  => '#' })
    JSON.parse(response).should == {"tropo"=>[{"conference"=>{"name"=>"foo", "mute"=>false, "sendTones"=>false, "id"=>"1234", "exitTone"=>"#"}}]}
  end
  
  it "should generate a complete 'conference' JSON document when a block is passed" do
    response = Tropo::Generator.conference({ :name       => 'foo', 
                                             :id         => '1234', 
                                             :mute       => false,
                                             :send_tones => false,
                                             :exit_tone  => '#' }) do
                                               on(:event => 'join') { say :value => 'Welcome to the conference' }
                                               on(:event => 'leave') { say :value => 'Someone has left the conference' }
                                             end
    JSON.parse(response).should == {"tropo"=>[{"conference"=>{"name"=>"foo", "mute"=>false, "id"=>"1234", "exitTone"=>"#", "sendTones"=>false, "on"=>[{"say"=>[{"value"=>"Welcome to the conference"}], "event"=>"join"}, {"say"=>[{"value"=>"Someone has left the conference"}], "event"=>"leave"}]}}]}
  end
  
  it "should generate an error if an 'conference' is passed without a 'name' parameter" do
    begin
      response = Tropo::Generator.conference({ :foo => 'bar' })
    rescue => err
      err.to_s.should == "A 'name' must be provided to a 'conference' action"
    end
  end
  
  it "should generate an error if an 'conference' is passed without an 'id' parameter" do
    begin
      response = Tropo::Generator.conference({ :name => 'bar' })
    rescue => err
      err.to_s.should == "A 'id' must be provided to a 'conference' action"
    end
  end
  
  # Hangup action tests and Disconnect alias
  it "should generate a JSON document with a 'hangup' action" do
    response = Tropo::Generator.hangup
    JSON.parse(response).should == {"tropo"=>[{"hangup"=>nil}]}
  end
  
  it "should generate a JSON document with a 'disconnect' action" do
    response = Tropo::Generator.disconnect
    JSON.parse(response).should == {"tropo"=>[{"hangup"=>nil}]}
  end
  
  it "should generate a standard 'on' JSON document" do
    response = Tropo::Generator.on({ :event => 'hangup', :next => 'myresource' })
    JSON.parse(response).should == { "tropo" => [{ "on" =>{ "event" => "hangup", "next" => "myresource" } }] }
  end
  
  # On tests
  it "should generate a an error of an 'on' document does not pass an event param" do
    begin
      response = Tropo::Generator.on({ :foo => 'bar' })
    rescue => err
      err.to_s.should == "A 'event' must be provided to a 'on' action"
    end
  end
  
  it "should generate a an error of an 'on' document does not pass an event param" do
    begin
      response = Tropo::Generator.on({ :event => 'bar' })
    rescue => err
      err.to_s.should == "A 'next' resource must be provided"
    end
  end
  
  # Record action tests
  it "should generate a complete 'record' JSON document" do
    response = Tropo::Generator.record({ :name       => 'foo', 
                                         :url        => 'http://sendme.com/tropo', 
                                         :beep       => true,
                                         :send_tones => false,
                                         :exit_tone  => '#' })
    JSON.parse(response).should == {"tropo"=>[{"record"=>{"name"=>"foo", "beep"=>true, "url"=>"http://sendme.com/tropo", "exitTone"=>"#", "sendTones"=>false}}]}
  end
  
  it "should generate a complete 'record' JSON document when a block is passed" do
    response = Tropo::Generator.record({ :name       => 'foo', 
                                         :url        => 'http://sendme.com/tropo', 
                                         :beep       => true,
                                         :send_tones => false,
                                         :exit_tone  => '#' }) do
                                           say     :value => 'Please say your account number'
                                           choices :value => '[5 DIGITS]'
                                         end
    JSON.parse(response).should == {"tropo"=>[{"record"=>{"name"=>"foo", "say"=>[{"value"=>"Please say your account number"}], "beep"=>true, "url"=>"http://sendme.com/tropo", "sendTones"=>false, "exitTone"=>"#", "choices"=>{"value"=>"[5 DIGITS]"}}}]}
  end
  
  it "should generate an error if an 'record' is passed without a 'name' parameter" do
    begin
      response = Tropo::Generator.record({ :foo => 'bar' })
    rescue => err
      err.to_s.should == "A 'name' must be provided to a 'record' action"
    end
  end
  
  it "should generate an error if an 'record' is passed without an 'url' parameter" do
    begin
      response = Tropo::Generator.record({ :name => 'bar' })
    rescue => err
      err.to_s.should == "A 'url' must be provided to a 'record' action"
    end
  end
  
  it "should generate an error if an 'record' is passed without an invalid 'url' parameter" do
    begin
      response = Tropo::Generator.record({ :name => 'bar',
                                           :url  => 'foobar' })
    rescue => err
      err.to_s.should == "The 'url' paramater must be a valid URL"
    end
  end
  
  it "should accept a valid email address when a 'record' action is called" do
    response = Tropo::Generator.record({ :name => 'bar',
                                         :url  => 'foo@bar.com' })
    response.should == "{\"tropo\":[{\"record\":{\"url\":\"foo@bar.com\",\"name\":\"bar\"}}]}"
  end
  
  # Redirect action tests
  it "should generate a JSON document with a 'redirect' action" do
    response = Tropo::Generator.redirect({ :to => 'sip:1234', :from => '4155551212' })
    JSON.parse(response).should == {"tropo"=>[{"redirect"=>{"from"=>"4155551212", "to"=>"sip:1234"}}]}
  end
  
  it "should generate an error if a 'redirect' action is included in a block" do
    begin
      response = Tropo::Generator.conference(:name => 'foobar', :id => 1234) do
                                             redirect(:to => 'sip:1234', :from => '4155551212')
                                           end
    rescue => err
      err.to_s.should == 'Redirect should only be used alone and before the session is answered, use transfer instead'
    end
  end
  
  it "should generate an error when no 'to' is passed to a 'redirect' action" do
    begin
      response = Tropo::Generator.redirect
    rescue => err
      err.to_s.should == "A 'to' must be provided to a 'redirect' action"
    end
  end
  
  # Reject action tests
  it "should generate a JSON document with a 'reject' action" do
    response = Tropo::Generator.reject
    JSON.parse(response).should == {"tropo"=>[{"reject"=>nil}]}
  end
  
  # Say action tests
  it "should generate a standard 'say' JSON document when a stiring is passed" do
    JSON.parse(Tropo::Generator.say('1234')).should == { "tropo" => [{ "say" => [{ "value" => "1234" }] }] }
  end
  
  it "should generate an error if I try to pass an integer to a 'say' action" do
    begin
      Tropo::Generator.say(1234)
    rescue => err
      err.to_s.should == "An invalid paramater type Fixnum has been passed"
    end
  end
  
  it "should generate a standard 'say' JSON document" do
    JSON.parse(Tropo::Generator.say({ :value => '1234' })).should == { "tropo" => [{ "say" => [{ "value" => "1234" }] }] }
  end
  
  it "should generate a 'say' JSON document when an array of values is passed" do
    response = Tropo::Generator.say([{ :value => '1234' }, { :value => 'abcd', :event => 'nomatch:1' }])
    JSON.parse(response).should == { "tropo" => [{ "say" => [{ "value" => "1234" }, { "value" => "abcd", "event"=>"nomatch:1" }] }] }
  end
  
  it "should generate an error if no 'value' key is passed to a 'say' request" do
    begin
      response = Tropo::Generator.say({ :name => 'foo' })
    rescue => err
      err.to_s.should == "A 'value' must be provided to a 'say' action"
    end
  end
  
  it "should generate a JSON document with a 'say' and an 'on'" do
    result = Tropo::Generator.new do
      say :value => 'blah'
      on  :event => 'error', :next => 'error.json'
    end
    JSON.parse(result.response).should == {"tropo"=>[{"say"=>[{"value"=>"blah"}]}, {"on"=>{"event"=>"error", "next"=>"error.json"}}]}
  end
  
  # Start & Stop Recording actions tests
  it "should generate a JSON document with a 'start_recording' action" do
    response = Tropo::Generator.start_recording(:name => 'recording', :url => 'http://postrecording.com/tropo')
    JSON.parse(response).should == {"tropo"=>[{"startRecording"=>{"name"=>"recording", "url"=>"http://postrecording.com/tropo"}}]}
  end
  
  it "should generate a JSON document with a 'stoprecording' action" do
    response = Tropo::Generator.stop_recording
    JSON.parse(response).should == {"tropo"=>[{"stopRecording"=>nil}]}
  end
  
  # Transfer action tests
  it "should generate a JSON document with a 'transfer' action" do
    response = Tropo::Generator.transfer(:to => 'tel:+14157044517')
    JSON.parse(response).should == {"tropo"=>[{"transfer"=>{"to"=>"tel:+14157044517"}}]}
  end
  
  # Transfer action tests
  it "should generate a JSON document with a 'transfer' action with an 'on' and 'choices' actions" do
    response = Tropo::Generator.transfer(:to => 'tel:+14157044517') do
      on :event => 'unbounded', :next => '/error.json'
      choices :value => '[5 DIGITS]'
    end
    JSON.parse(response).should == {"tropo"=>[{"transfer"=>{"to"=>"tel:+14157044517", "choices"=>{"value"=>"[5 DIGITS]"}, "on"=>[{"event"=>"unbounded", "next"=>"/error.json"}]}}]}
  end
  
  it "should generate an error if no 'to' key is passed to a 'transfer' request" do
    begin
      response = Tropo::Generator.transfer
    rescue => err
      err.to_s.should == "A 'to' must be provided to a 'transfer' action"
    end
  end
  
  # General tests
  it "should generate a JSON document when a block is passed" do
    result = Tropo::Generator.new do
      say [{ :value => '1234' }, { :value => 'abcd', :event => "nomatch:1" }]
      say [{ :value => '0987' }, { :value => 'zyxw', :event => "nomatch:2" }]
    end
    JSON.parse(result.response).should == {"tropo"=>[{"say"=>[{"value"=>"1234"}, {"value"=>"abcd", "event"=>"nomatch:1"}]}, {"say"=>[{"value"=>"0987"}, {"value"=>"zyxw", "event"=>"nomatch:2"}]}]}
  end
  
  it "should build a Ruby hash object when a session arrives in JSON" do
    json_session = "{\"session\":{\"id\":\"dih06n\",\"accountId\":\"33932\",\"timestamp\":\"2010-01-19T23:18:48.562Z\",\"userType\":\"HUMAN\",\"to\":{\"id\":\"tropomessaging@bot.im\",\"name\":\"unknown\",\"channel\":\"TEXT\",\"network\":\"JABBER\"},\"from\":{\"id\":\"john_doe@gmail.com\",\"name\":\"unknown\",\"channel\":\"TEXT\",\"network\":\"JABBER\"}}}"
    hash = Tropo::Generator.parse(json_session)
    hash[:session][:timestamp] == Time.parse('2010-01-19T18:27:46.852-05:00')
  end
  
  it "should build a Ruby hash object when a result arrives in JSON" do
    json_result = "{\"result\":{\"sessionId\":\"sessionId\",\"callState\":\"ANSWERED\",\"sessionDuration\":10,\"sequence\":1,\"complete\":true,\"error\":\"error\",\"properties\":[{\"key\":\"foo\",\"value\":\"bar\"},{\"key\":\"charlie\",\"value\":\"foxtrot\"}],\"actions\":{\"name\":\"pin\",\"attempts\":1,\"disposition\":\"SUCCESS\",\"confidence\":100,\"interpretation\":\"12345\",\"utterance\":\"1 2 3 4 5\"}}}"
    Tropo::Generator.parse(json_result).should == {:result=>{:session_id=>"sessionId", :properties=>{:foo=>{:value=>"bar"}, :charlie=>{:value=>"foxtrot"}}, :complete=>true, :call_state=>"ANSWERED", :actions=>{:pin=>{:disposition=>"SUCCESS", :utterance=>"1 2 3 4 5", :attempts=>1, :interpretation=>"12345", :confidence=>100}}, :session_duration=>10, :error=>"error", :sequence=>1}}
  end
  
  it "should build a ruby hash object when a realworld JSON string arrives" do
    json_result = "{\"result\":{\"sessionId\":\"CCFD9C86-1DD1-11B2-B76D-B9B253E4B7FB@161.253.55.20\",\"callState\":\"ANSWERED\",\"sessionDuration\":2,\"sequence\":1,\"complete\":true,\"error\":null,\"actions\":[{\"name\":\"zip\",\"attempts\":1,\"disposition\":\"SUCCESS\",\"confidence\":100,\"interpretation\":\"12345\",\"utterance\":\"1 2 3 4 5\"},{\"name\":\"days\",\"attempts\":1,\"disposition\":\"SUCCESS\",\"confidence\":100,\"interpretation\":\"1\",\"utterance\":\"1\"}]}}"
    Tropo::Generator.parse(json_result).should == {:result=>{:call_state=>"ANSWERED", :complete=>true, :actions=>{:zip=>{:disposition=>"SUCCESS", :utterance=>"1 2 3 4 5", :attempts=>1, :interpretation=>"12345", :confidence=>100}, :days=>{:disposition=>"SUCCESS", :utterance=>"1", :attempts=>1, :interpretation=>"1", :confidence=>100}}, :session_duration=>2, :sequence=>1, :session_id=>"CCFD9C86-1DD1-11B2-B76D-B9B253E4B7FB@161.253.55.20", :error=>nil}}
  end
  
  it "should see an object delcared outside of a block" do
    @@session = 'foobar'
    result = Tropo::Generator.new do
      @@new_session = @@session
      say :value => 'blah'
      on  :event => 'error', :next => 'error.json'
    end
    @@new_session.should == 'foobar'
  end
  
  it "should see an object passed into the block" do
    session = 'foobar'
    result = Tropo::Generator.new(session) do
      session.should == 'foobar'
      say :value => 'blah'
      on  :event => 'error', :next => 'error.json'
    end
  end
  
  it "should allow you to create a Tropo::Generator object and build up a JSON request with two says" do
    tropo = Tropo::Generator.new
    tropo.say('foo')
    tropo.say('bar')
    tropo.response.should == "{\"tropo\":[{\"say\":[{\"value\":\"foo\"}]},{\"say\":[{\"value\":\"bar\"}]}]}"
  end
  
  it "should allow you to create a Tropo::Generator object and build up a JSON request with: a say, an on and a record" do
    tropo = Tropo::Generator.new
    tropo.say 'Welcome to the app'
    tropo.on :event => 'hangup', :next => '/hangup.json'
    tropo.record({ :name => 'foo', 
                   :url        => 'http://sendme.com/tropo', 
                   :beep       => true,
                   :send_tones => false,
                   :exit_tone  => '#' }) do
                     say     :value => 'Please say your account number'
                     choices :value => '[5 DIGITS]'
                   end
    JSON.parse(tropo.response).should == {"tropo"=>[{"say"=>[{"value"=>"Welcome to the app"}]}, {"on"=>{"event"=>"hangup", "next"=>"/hangup.json"}}, {"record"=>{"name"=>"foo", "say"=>[{"value"=>"Please say your account number"}], "beep"=>true, "url"=>"http://sendme.com/tropo", "sendTones"=>false, "exitTone"=>"#", "choices"=>{"value"=>"[5 DIGITS]"}}}]}
  end
  
  it "should allow you to reset the object to a fresh response after building a response first" do
    tropo = Tropo::Generator.new
    tropo.say 'Welcome to the app'
    tropo.on :event => 'hangup', :next => '/hangup.json'
    tropo.record({ :name => 'foo', 
                   :url        => 'http://sendme.com/tropo', 
                   :beep       => true,
                   :send_tones => false,
                   :exit_tone  => '#' }) do
                     say     :value => 'Please say your account number'
                     choices :value => '[5 DIGITS]'
                   end
    JSON.parse(tropo.response).should == {"tropo"=>[{"say"=>[{"value"=>"Welcome to the app"}]}, {"on"=>{"event"=>"hangup", "next"=>"/hangup.json"}}, {"record"=>{"name"=>"foo", "say"=>[{"value"=>"Please say your account number"}], "beep"=>true, "url"=>"http://sendme.com/tropo", "sendTones"=>false, "exitTone"=>"#", "choices"=>{"value"=>"[5 DIGITS]"}}}]}
    tropo.reset
    tropo.response.should == "{\"tropo\":[]}"
  end
  
  it "should build a Ruby hash object when a session arrives in JSON with a proper Ruby Time object" do
    json_session = "{\"session\":{\"id\":\"dih06n\",\"accountId\":\"33932\",\"timestamp\":\"2010-01-19T23:18:48.562Z\",\"userType\":\"HUMAN\",\"to\":{\"id\":\"tropomessaging@bot.im\",\"name\":\"unknown\",\"channel\":\"TEXT\",\"network\":\"JABBER\"},\"from\":{\"id\":\"john_doe@gmail.com\",\"name\":\"unknown\",\"channel\":\"TEXT\",\"network\":\"JABBER\"}}}"
    hash = Tropo::Generator.parse(json_session)
    hash[:session][:timestamp].should == Time.parse("2010-01-19T23:18:48.562Z")
  end
  
  it "should build a Ruby hash object when a result arrives in JSON with one action returned in an array" do
    json_result = "{\"result\":{\"sessionId\":\"CCFD9C86-1DD1-11B2-B76D-B9B253E4B7FB@161.253.55.20\",\"callState\":\"ANSWERED\",\"sessionDuration\":2,\"sequence\":1,\"complete\":true,\"error\":null,\"actions\":{\"name\":\"zip\",\"attempts\":1,\"disposition\":\"SUCCESS\",\"confidence\":100,\"interpretation\":\"12345\",\"utterance\":\"1 2 3 4 5\"}}}"
    hash = Tropo::Generator.parse(json_result)
    hash.should == {:result=>{:call_state=>"ANSWERED", :complete=>true, :actions=>{:zip=>{:utterance=>"1 2 3 4 5", :attempts=>1, :interpretation=>"12345", :confidence=>100, :disposition=>"SUCCESS"}}, :session_id=>"CCFD9C86-1DD1-11B2-B76D-B9B253E4B7FB@161.253.55.20", :session_duration=>2, :error=>nil, :sequence=>1}}
  end
  
  it "should generate valid JSON when a startRecording is used" do
    t = Tropo::Generator.new
    t.on :event => 'error', :next => '/error.json' # For fatal programming errors. Log some details so we can fix it
    t.on :event => 'hangup', :next => '/hangup.json' # When a user hangs or call is done. We will want to log some details.
    t.on :event => 'continue', :next => '/next.json'
    t.say "Hello"
    t.start_recording(:name => 'recording', :url => "http://heroku-voip.marksilver.net/post_audio_to_s3?filename=foo.wav&unique_id=bar")
    # [From this point, until stop_recording(), we will record what the caller *and* the IVR say]
    t.say "You are now on the record."
    # Prompt the user to incriminate themselve on-the-record
    t.say "Go ahead, sing-along."
    t.say "http://denalidomain.com/music/keepers/HappyHappyBirthdaytoYou-Disney.mp3"
    JSON.parse(t.response).should == {"tropo"=>[{"on"=>{"event"=>"error", "next"=>"/error.json"}}, {"on"=>{"event"=>"hangup", "next"=>"/hangup.json"}}, {"on"=>{"event"=>"continue", "next"=>"/next.json"}}, {"say"=>[{"value"=>"Hello"}]}, {"startRecording"=>{"name"=>"recording", "url"=>"http://heroku-voip.marksilver.net/post_audio_to_s3?filename=foo.wav&unique_id=bar"}}, {"say"=>[{"value"=>"You are now on the record."}]}, {"say"=>[{"value"=>"Go ahead, sing-along."}]}, {"say"=>[{"value"=>"http://denalidomain.com/music/keepers/HappyHappyBirthdaytoYou-Disney.mp3"}]}]}
  end
  
  it "should generate a voice_session true if a JSON session is received that is a channel of 'VOICE'" do
    tropo = Tropo::Generator.new
    tropo.parse "{\"session\":{\"id\":\"0-13c4-4b563da3-7aecefda-46af-1d10bdd0\",\"accountId\":\"33932\",\"timestamp\":\"2010-01-19T23:18:00.854Z\",\"userType\":\"HUMAN\",\"to\":{\"id\":\"9991427589\",\"name\":\"unknown\",\"channel\":\"VOICE\",\"network\":\"PSTN\"},\"from\":{\"id\":\"jsgoecke\",\"name\":\"unknown\",\"channel\":\"VOICE\",\"network\":\"PSTN\"}}}"
    tropo.voice_session.should == true
    tropo.text_session.should == false
  end
  
  it "should generate a text_session true if a JSON session is received that is a channel of 'TEXT'" do
    tropo = Tropo::Generator.new
    tropo.parse "{\"session\":{\"id\":\"dih06n\",\"accountId\":\"33932\",\"timestamp\":\"2010-01-19T23:18:48.562Z\",\"userType\":\"HUMAN\",\"to\":{\"id\":\"tropomessaging@bot.im\",\"name\":\"unknown\",\"channel\":\"TEXT\",\"network\":\"JABBER\"},\"from\":{\"id\":\"john_doe@gmail.com\",\"name\":\"unknown\",\"channel\":\"TEXT\",\"network\":\"JABBER\"}}}"
    tropo.voice_session.should == false
    tropo.text_session.should == true
  end

end