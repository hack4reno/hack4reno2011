class UsersController < ApplicationController
    
  def show
    # @listeners = user.listeners.by_count.all(:limit => 25)
    @user = user
  end
  
  def tweetcall
    
    if current_user
      refnumber = 1 + rand(1000)
      # message = "calling @#{params[:twele][:target]} using http://twelephone.com ref:#{refnumber.to_s}"
      # @tweet = current_user.twitter.post('/statuses/update.json', :status => message)  
    
      target = User.find(:first, :conditions => ['login = ?', params[:twele][:target].downcase])
    end
    
    render :update do |page| 
      if !current_user
        page.replace_html 'results', 'Please login to place a twelephone call...'
      elsif target
        page.replace_html 'results', "<script>popitup('/call/" + params[:twele][:target] + "');</script>"
      else
        message = "@#{params[:twele][:target]} @#{current_user.login} is trying to call you using http://twelephone.com but you're not registered."
        @tweet = current_user.twitter.post('/statuses/update.json', :status => message)  
        
        page.replace_html 'results', 'We just sent @' + params[:twele][:target] + ' a requst to signup for Twelephone...'
      end
      page.visual_effect :highlight, 'results', :duration => 1
    end
  end
  
  def updatephone
    @user = User.find(current_user.id)
    @user.phone = params[:twele][:phone]
    @user.save
    render :action => 'show'
  end
    
  protected
  
  def user
    @user ||= User.from_param(params[:id])
  end
  helper_method :user
end
