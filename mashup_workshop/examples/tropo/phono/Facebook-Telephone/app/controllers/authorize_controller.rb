class AuthorizeController < ApplicationController
  
# http://developers.facebook.com/docs/api#authorization
# 
# Telephone Oauth login
# https://graph.facebook.com/oauth/authorize?client_id=104425026288823&redirect_uri=http://telephone.heroku.com/oauth_redirect
# 
# FB Response 1
# http://telephone.heroku.com/oauth_redirect?code=2.gtz_CSXhMbzSaWls9CyNwg__.3600.1285297200-1115105088|zrj2UMz6YyuLw07fCO8_Fudm_o4
# 
# Telephone Response 2
# https://graph.facebook.com/oauth/access_token?client_id=104425026288823&redirect_uri=http://telephone.heroku.com/oauth_redirect&client_secret=a4807180f4586dc5df989d4d03e242b1&code=2.gtz_CSXhMbzSaWls9CyNwg__.3600.1285297200-1115105088|zrj2UMz6YyuLw07fCO8_Fudm_o4
# 
# FB Response 2
# access_token=104425026288823|2.gtz_CSXhMbzSaWls9CyNwg__.3600.1285297200-1115105088|VUEJHNws20FitmBxSRrEx1EeH2U&expires=3317
# 
# Telephone current user request 
# https://graph.facebook.com/me?access_token=104425026288823|2.gtz_CSXhMbzSaWls9CyNwg__.3600.1285297200-1115105088|VUEJHNws20FitmBxSRrEx1EeH2U&expires=3317
# 
# FB Response
# {
#    "id": "1115105088",
#    "name": "Chris Matthieu",
#    "first_name": "Chris",
#    "last_name": "Matthieu",
#    "link": "http://www.facebook.com/chrismatthieu",
#    "gender": "male",
#    "email": "chris@matthieu.us",
#    "timezone": -7,
#    "locale": "en_US",
#    "verified": true,
#    "updated_time": "2010-08-22T09:03:24+0000"
# }
  
  def new
    
    #Consider adding this URL to Facebook app starting URL
    oauthurl = "https://graph.facebook.com/oauth/authorize?client_id=104425026288823&redirect_uri=http://telephone.heroku.com/oauth_redirect"
    redirect_to oauthurl
        
  end
  
  def oauth_redirect
    code = params[:code]
    
    # # begin
    #   resp = RestClient.get "https://graph.facebook.com/oauth/access_token", {:params => {:client_id => "104425026288823", :redirect_uri => 'http://telephone.heroku.com/oauth_redirect', :client_secret => 'a4807180f4586dc5df989d4d03e242b1', :code => code}}
    # # rescue => e
    # #   puts e.response
    # # end

    require "net/https"
    require "uri"
    begin
      uri = URI.parse("https://graph.facebook.com/oauth/access_token?client_id=104425026288823&client_secret=a4807180f4586dc5df989d4d03e242b1&code=" + code + "&redirect_uri=http://telephone.heroku.com/oauth_redirect")
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      request = Net::HTTP::Get.new(uri.request_uri)
      resp = http.request(request)
    rescue => e
      resp = nil
    end
    

    sleep 1 # Is this necessary?
    
    if !resp.nil? and resp.body
      mytoken = resp.body.gsub("access_token=", "")

      accesstoken = mytoken.split("&")[0]
      expires = mytoken.split("&")[1].gsub('expires=', '')
      
      #Now fetch and update user data
        #FOR SOME REASON RESTCLIENT DIDN'T WORK
        # userresp = RestClient.get "https://graph.facebook.com/me", {:params => {:access_token => URI.escape(accesstoken), :expires => expires}} 
        

      # require "net/https"
      # require "uri"
      begin
        uri2 = URI.parse("https://graph.facebook.com/me?access_token=" + URI.escape(mytoken))
        http2 = Net::HTTP.new(uri2.host, uri2.port)
        http2.use_ssl = true
        http2.verify_mode = OpenSSL::SSL::VERIFY_NONE
        request2 = Net::HTTP::Get.new(uri2.request_uri)
        userresp = http2.request2(request)
      rescue => e
        userresp = nil
      end
        

      if !userresp.nil? and userresp.body
        data = userresp.body
        result = JSON.parse(data)
        
        @user = User.find_by_facebookid(result["id"])
        if @user.nil?
          @user = User.new
        end

        @user.facebookid = result["id"]
        @user.name = result["name"]
        @user.firstname = result["first_name"]
        @user.lastname = result["last_name"]
        @user.link = result["link"]
        @user.gender = result["gender"]
        @user.email = result["email"]
        @user.timezone = result["timezone"]
        @user.local = result["locale"]
        @user.verified = result["verified"]
        @user.token = accesstoken
        @user.save
        
        session["id"] = result["id"]
        session["usertoken"] = accesstoken

      end
    end

    redirect_to '/facebook'

  end

end
