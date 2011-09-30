class StaticController < ApplicationController
    
  def index
    @users = User.all(:order => "created_at DESC", :limit => 16)
    
    if logged_in?
      # @skypes = Skype.find(:first, :conditions => ["user_id = ?", current_user])
      
      # if !@skypes 
      #   @skype = Skype.new
      #   redirect_to :controller => 'skypes', :action => 'new'
      # end
      
    end
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
        @user = User.find_by_login(userid)
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
          if @user.phone
            phoneraw = @user.phone.gsub("-", "").gsub("(", "").gsub(")", "").gsub("+", "")
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
    @user = current_user
    @user.sip = params[:mysession]      
    @user.save
    
    render :update do |page|
      # page.alert "phono address:  #{@user.phonoaddress}"
    end
  end
  
  
  def twelephoneversion
    #http://twelephone.com/apps/spaz/AIR/UpdateDescriptor.json
    version = '{

     newestVersion:\'0.8.5\',
     description:"This is the <strong>description!</strong>",
     newestURL:"http://twelephone.com/TwelephoneAIR.air",
     isTest:false

    }'

    #newestURL:"http://twelephone.com/apps/spaz/AIR/SpazAIR.air",
    
    render :text => version, :layout => false
  end
  
  def twitterpoll
    
    # # SCHEDULER THAT POLLS EVERY MINUTE TO CHECK FOR #TWELEPHONE REQUESTS
    # require 'rubygems'
    # require 'rest_client'
    # require 'json'
    # 
    # 
    #   # res = RestClient.get URI.encode('http://itpints.com/api/search?q=twelephone') rescue ''  
    #   res = RestClient.get URI.encode('http://search.twitter.com/search.json?q=twelephone') #rescue nil
    #   result = JSON.parse(res)
    # 
    #   # if !result['results']['created_at'].nil?
    # 
    #     result['results'].each do |u| 
    # 
    #       if !u['text'].nil? and u['text'].index("#twelephone") 
    #         # puts u['id']
    # 
    #       calls = Call.find(:first, :conditions => ['twitterids = ?', u['id'].to_s]) #rescue false
    #       # puts ">"
    #       if !calls
    #         # puts "<"
    #         # if !u['to_user'].nil?
    #         #   target = u['to_user']
    #         # else
    #           target = u['text'].scan(/@([A-Za-z0-9_]+)/) rescue ''
    #         # end
    # 
    #         logit = Call.new
    #         logit.twitterids = u['id'].to_s
    #         logit.author = u['from_user']
    #         logit.target = target[0]
    #         logit.save
    # 
    #         # source = User.find(:first, :conditions => ['UPPER(login) = ?', u['author'].upcase]) rescue false
    #         # destination = User.find(:first, :conditions => ['UPPER(login) = ?', target[0].upcase]) rescue false
    #         source = User.find(:first, :conditions => ['login = ?', u['from_user'] ]) #rescue false
    #         destination = User.find(:first, :conditions => ['login = ?', target[0].to_s ]) #rescue false
    # 
    #         if source and destination
    #             dial = RestClient.get URI.encode('http://teleku.com/connect/' + source.phone + '/' + destination.phone + '?apikey=ba6a5304-905a-4938-811c-351020b8fdf6' ) rescue '' 
    #             # puts URI.encode('http://teleku.com/connect/' + source.phone + '/' + destination.phone + '?apikey=ba6a5304-905a-4938-811c-351020b8fdf6' )
    # 
    #         elsif source.nil?
    # 
    #           if u['from_user'].downcase != 'twelephoneapp'
    #             resource = RestClient::Resource.new 'http://twitter.com/statuses/update.xml', :user => 'twelephoneapp', :password => 'dvtdvt'
    #             resource.post :status => '@' + u['from_user'] + ': Before giving someone a twelephone call, you must register at http://twelephone.com!', :content_type => 'application/xml'
    #           end
    # 
    #         elsif destination.nil?
    # 
    #           resource = RestClient::Resource.new 'http://twitter.com/statuses/update.xml', :user => 'twelephoneapp', :password => 'dvtdvt'
    #           resource.post :status => '@' + target[0].to_s + ': @' + u['from_user'] + ' is trying to give you a twelephone call. Register at http://twelephone.com!', :content_type => 'application/xml'
    # 
    # 
    #         end
    # 
    #       end
    #     end
    #   end
      
      render :text => 'success', :layout => false
          
  end
  
  
end
