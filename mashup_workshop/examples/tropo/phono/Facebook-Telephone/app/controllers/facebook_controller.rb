class FacebookController < ApplicationController
  def index
    
    #Testing
    # session["id"] = "1115105088"
    # friends = nil

    if session["id"]
      
      # # Check to see if it's me 
      # user_json = access_token.get('/me')
      # if !user_json.nil? 
      #   result = JSON.parse(user_json)
      #   session["id"] = result["id"]
      # else
      #   session["id"] = nil
      # end

      @user = User.find_by_facebookid(session["id"])
    
      if @user
      
        session["phone"] = @user.phonenumber
     
        friends = RestClient.get "https://graph.facebook.com/me/friends", {:params => {:access_token => @user.token}} rescue nil
      
        # require "net/https"
        # require "uri"
        # begin
        #   uri = URI.parse("https://graph.facebook.com/me/friends?access_token=" + @user.token) 
        #   http = Net::HTTP.new(uri.host, uri.port)
        #   http.use_ssl = true
        #   http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        #   request = Net::HTTP::Get.new(uri.request_uri)
        #   friends = http.request(request)
        # rescue => e
        #   friends = nil
        # end
      
      
        if !friends.nil? and friends.body
          @friends = JSON.parse(friends.body)
        end
      
      # else
      #   redirect_to "http://telephone.heroku.com/oauth/start" #, {:target=>"_parent"}
      end 
    end
    
  end

  def show
  end
  
  def telephone
    # # format DID or SIP address properly -> /telephone/4805551212 or /telephone/sip:abc@sip.com
    # phone = params[:id] 
    # if phone
    #   phone = phone.gsub("-", "").gsub("(", "").gsub(")", "").gsub("+", "")
    #   if phone.index("@") and !phone.index("sip:")
    #     phone = "sip:" + phone
    #   end
    #   
    #   if isNumeric(phone) and phone.length == 10
    #     phone = "1" + phone
    #   end
    # 
    #   #Setup Dial (DID or SIP) | http://phono.com/16025551212
    #   if isNumeric(phone) 
    #     @did = phone
    #     # @phone = "sip:9991443313@sip.tropo.com" #;postd=p16025551212;pause=1000ms
    #     # @phone = "sip:9991443313@stagingsbc-external.orl.voxeo.net"
    #     # @phone = "sip:9991443313@sbcexternal.orl.voxeo.net"
    #     @phone = "app:9991443313"
    #   
    #   elsif phone.index('@') or phone.index('app:')
    #     @did = ""
    #     @phone = phone
    # 
    #   else
    #     # @did = "app:9991443124"
    #     # @phone = "app:9991443124"
    #     # @short = @phone
    #   
    #   end
    # end
    
    # Look up user by id and call their SIP address and posted number
    userid = params[:id]
    if userid      
      if userid.index("@")
        if !userid.index("sip:")
          @phone = "sip:" + userid
        else
          @phone = userid
        end
        @did = userid
        @display = userid
      else
        @user = User.find_by_facebookid(userid)
        if @user
          @transfermode = "one" # "all" = simultaneous rings or "one" = one phone at a time
          @did = ""
          if @user.sip
            sipraw = @user.sip
            if sipraw.index("@") and !sipraw.index("sip:")
              sipraw = "sip:" + sipraw
            end
            @did << sipraw + ","
          end
          if @user.phonenumber
            phoneraw = @user.phonenumber.gsub("-", "").gsub("(", "").gsub(")", "").gsub("+", "")
            if phoneraw.index("@") and !phoneraw.index("sip:")
              phoneraw = "sip:" + phoneraw
            end
            if isNumeric(phoneraw) and phoneraw.length == 10
              phoneraw = "1" + phoneraw
            end
            @did << phoneraw + ","
          end
          @did = @did.chop #remove last comma from @did string
          # @phone = "app:9991443419" # TROPO
          # @phone = "app:9991457150" # CCXML
          @phone = "sip:9991452579@stagingsbc-external.orl.voxeo.net"
        end
      end
    else
      # @display = "Enter number to dial"
      @display = ""
    end
    render 'phono', :layout => false
    
  end
  
  def update_phonoaddress
    # Receives AJAX call to report telephone SIP address
    @user = User.find_by_facebookid(session["id"])
    @user.sip = params[:mysession]      
    @user.save
    
    render :update do |page|
      # page.alert "phono address:  #{@user.phonoaddress}"
    end
  end
  
  def numberupdate
    @user = User.find_by_facebookid(session["id"])
    if @user
      @user.phonenumber = params[:phonenumber]
      @user.save
      session["phone"] = @user.phonenumber
    end
    render :update do |page|
      # page.alert "phono address:  #{@user.phonoaddress}"
      page.replace_html('mynumber', '<input onclick="RedBox.showInline(\'inline_phone\');" type="button" value="' + session["phone"] + '"/>')
      page.RedBox.close(); 
    end
  end
  
end
