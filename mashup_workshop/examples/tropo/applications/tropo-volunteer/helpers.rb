require 'time'

def construct_details_string(item)
  tinyurl = shorten_url(URI.unescape(item["xml_url"]))
  details = []
  details << "From #{pretty_time(item["startDate"])} to #{pretty_time(item["endDate"])}" unless item["startDate"].empty? or item["endDate"].empty?      
  if session[:channel] == "VOICE"
    details << "Official web page: #{readable_tinyurl(tinyurl)}. Again, that's #{readable_tinyurl(tinyurl)}"
  else
    details << "Official web page: #{tinyurl}"
  end
  details << "Name: " + item["contactName"] unless item["contactName"].empty?
  details << "Phone: " + item["contactPhone"] unless item["contactPhone"].empty?
  details << "Email: " + item["contactEmail"] unless item["contactEmail"].empty?
  details << "Street: " + item["street1"] unless item["street1"].empty?
  details << "Street: " + item["street2"] unless item["street2"].empty?
  if session[:channel] == "VOICE"
    details << "Google Map: " + readable_tinyurl(shorten_url("http://maps.google.com/maps?f=q&source=s_q&hl=en&geocode=&q="+item["latlong"])) unless item["latlong"].empty?
  else
    details << "Google Map: " + shorten_url("http://maps.google.com/maps?f=q&source=s_q&hl=en&geocode=&q="+item["latlong"]) unless item["latlong"].empty?
  end
  return details.join(", ")
end

def shorten_url(long_url)
  short_url = open("http://tinyurl.com/api-create.php?url=#{long_url}").read.gsub(/https?:\/\//, "")
end

def readable_tinyurl(url)
  unique_url = url.split("/")[1].split(//).join(",")+","
  "tiny u r l dot com slash #{unique_url}"
end

def pretty_time(input)
  Time.parse(input).strftime("%A %B %d at %I:%M %p")
end