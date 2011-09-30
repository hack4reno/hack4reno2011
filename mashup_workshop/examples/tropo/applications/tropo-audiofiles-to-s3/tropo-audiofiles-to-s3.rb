%w(rubygems sinatra yaml logger aws/s3).each do |lib|
  require lib
end

# Open configuration for the app
APP_CONFIG = YAML.load(File.open('config/application.yml'))

# Start logger
log = Logger.new(APP_CONFIG['log_file'])
log.level = eval "Logger::#{APP_CONFIG['log_level']}"
log.info(APP_CONFIG['app_name'] + ' started @ ' + Time.now.to_s)
  
# Open configuration file and connect to Amazon
AWS_CONFIG = YAML.load(File.open('config/amazon_s3.yml'))
AWS::S3::Base.establish_connection!(
  :access_key_id     => AWS_CONFIG['access_key_id'],
  :secret_access_key => AWS_CONFIG['secret_access_key']
)

# Method that receives the file and sends to S3
post '/post_audio_to_s3' do
  log.debug params
  begin
    AWS::S3::S3Object.store(params['filename'][:filename], 
                            File.open(params['filename'][:tempfile].path), 
                            AWS_CONFIG['bucket_name'])
  rescue => err
    log.error err
  end
end