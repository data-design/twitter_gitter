$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'pry'
require 'webmock'
require 'vcr'

VCR.configure do |c|
  c.cassette_library_dir = './spec/fixtures/vcr_cassettes'
  c.hook_into :webmock
  c.configure_rspec_metadata!


  c.before_record do |i|
    i.request.headers['Authorization'] = {'oauth_version' => '100.0x'}
  end
end


RSpec.configure do |config|
  config.filter_run_excluding skip: true 
  config.run_all_when_everything_filtered = true
  config.filter_run :focus => true
  config.order = "random"
  # Use color in STDOUT
  config.color_enabled = true
  # Use the specified formatter
  config.formatter = :documentation # :progress, :html, :textmate
  # Use color not only in STDOUT but also in pagers and files
  config.tty = true

  config.mock_with :rspec do |mocks|
#    mocks.verify_partial_doubles = true
  end

end


# Create a YAML file that looks like:
#
#~~~yaml
# consumer_key: YOUR_CONSUMER_KEY
# consumer_secret: YOUR_SECRET
# access_token: ACCESS_TOKEN
# access_token_secret: ACCESS_TOKEN_SECRET
#~~~
SPEC_TWITTER_CREDS_FILE = File.expand_path("../.twitter_creds", __FILE__)
ENV['TWITTER_CREDS'] = SPEC_TWITTER_CREDS_FILE


require 'twitter_gitter'




