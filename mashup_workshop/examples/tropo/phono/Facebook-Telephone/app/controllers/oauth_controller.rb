# http://github.com/intridea/oauth2
# http://github.com/intridea/oauth2/wiki

class OauthController < ApplicationController
  
  def start
    redirect_to client.web_server.authorize_url(
      :redirect_uri => 'http://telephone.heroku.com/oauth/callback'
    )
  end

  def callback
    access_token = client.web_server.get_access_token(
      params[:code], :redirect_uri => 'http://telephone.heroku.com/oauth/callback'
    )

    user_json = access_token.get('/me')
    
    if !user_json.nil? 
      
      result = JSON.parse(user_json)

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
      @user.token = access_token.token
      @user.save
      
      session["id"] = result["id"]
      session["usertoken"] = access_token.token

    end
    
    # redirect_to 'http://telephone.heroku.com/facebook'
    redirect_to 'http://apps.facebook.com/telephone'
    
  end

  protected

  def client
    @client ||= OAuth2::Client.new(
      '104425026288823', 'a4807180f4586dc5df989d4d03e242b1', :site => 'https://graph.facebook.com'
    )
  end
end
