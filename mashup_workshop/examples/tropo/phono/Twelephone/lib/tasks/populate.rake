# 
# namespace :utils do
#   
#   # Populates feeds table.
#   task(:populate_feeds => :environment) do
# 
#     # SCHEDULER THAT POLLS EVERY MINUTE TO CHECK FOR #TWELEPHONE REQUESTS
#     require 'rubygems'
#     require 'rest_client'
#     require 'json'
# 
# 
#       # res = RestClient.get URI.encode('http://itpints.com/api/search?q=twelephone') rescue ''  
#       res = RestClient.get URI.encode('http://search.twitter.com/search.json?q=twelephone') #rescue nil
#       result = JSON.parse(res)
# 
#       # if !result['results']['created_at'].nil?
# 
#         result['results'].each do |u| 
# 
#           if !u['text'].nil? and u['text'].index("#twelephone") 
#             # puts u['id']
# 
#           calls = Call.find(:first, :conditions => ['twitterids = ?', u['id'].to_s]) rescue false
#           # puts ">"
#           if !calls
#             # puts "<"
#             # if !u['to_user'].nil?
#             #   target = u['to_user']
#             # else
#               target = u['text'].scan(/@([A-Za-z0-9_]+)/) rescue ''
#             # end
# 
#             logit = Call.new
#             logit.twitterids = u['id'].to_s
#             logit.author = u['from_user']
#             logit.target = target[0]
#             logit.save
# 
#             # source = User.find(:first, :conditions => ['UPPER(login) = ?', u['author'].upcase]) rescue false
#             # destination = User.find(:first, :conditions => ['UPPER(login) = ?', target[0].upcase]) rescue false
#             source = User.find(:first, :conditions => ['login LIKE ?', '%' + u['from_user'] + '%']) #rescue false
#             destination = User.find(:first, :conditions => ['login LIKE ?', '%' + target[0].to_s + '%']) #rescue false
# 
#             if source and destination
#                 dial = RestClient.get URI.encode('http://teleku.com/connect/' + source.phone + '/' + destination.phone + '?apikey=ba6a5304-905a-4938-811c-351020b8fdf6' ) rescue '' 
#                 # puts URI.encode('http://teleku.com/connect/' + source.phone + '/' + destination.phone + '?apikey=ba6a5304-905a-4938-811c-351020b8fdf6' )
# 
#             elsif source.nil?
# 
#               if u['from_user'].downcase != 'twelephoneapp'
#                 resource = RestClient::Resource.new 'http://twitter.com/statuses/update.xml', :user => 'twelephoneapp', :password => 'dvtdvt'
#                 resource.post :status => '@' + u['from_user'] + ': Before giving someone a twelephone call, you must register at http://twelephone.com!', :content_type => 'application/xml'
#               end
# 
#             elsif destination.nil?
# 
#               resource = RestClient::Resource.new 'http://twitter.com/statuses/update.xml', :user => 'twelephoneapp', :password => 'dvtdvt'
#               resource.post :status => '@' + target[0].to_s + ': @' + u['from_user'] + ' is trying to give you a twelephone call. Register at http://twelephone.com!', :content_type => 'application/xml'
# 
# 
#             end
# 
#           end
#         end
#       end
#     
#   end
# 
# 
#   
# end
