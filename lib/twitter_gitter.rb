require "twitter_gitter/version"


require 'twitter'
require 'hashie'
require 'yaml'

class TwitterGitter

# Set the convention that ENV['TWITTER_CREDS'] points to a YAML filename
  DEFAULT_KEY_FILE = ENV['TWITTER_CREDS']

# Set default parameters for a catch-all for what's publicly available on
# any given user's timeline, according to Twitter docs:
# https://dev.twitter.com/docs/api/1.1/get/statuses/user_timeline
  MAX_BATCH_SIZE_USERS = 100
  MAX_BATCH_SIZE_TWEETS = 200
  BASIC_TIMELINE_OPTS = { 
# We don't need to save the user object, since presumably we know who the user is    
    trim_user: true, 
    include_rts: true,
    since_id: 0,
    count: MAX_BATCH_SIZE_TWEETS
  }


# Kind of a holdover, but give the user the option of just accessing the client object directly.
# It at least makes it easier to prototype new things
  attr_reader :client

  def initialize(key=DEFAULT_KEY_FILE)
    @client = TwitterGitter.initialize_client(key)
  end

  # convenience method, just returns the single user
  def fetch_user(id)
    fetch( :user, id ).last_result
  end

  def fetch_users(ids, &blk)
    ids = Array(ids)
    status = nil

    ids.each_slice(MAX_BATCH_SIZE_USERS) do |arr|
      status = fetch status, :users, arr, &blk
    end

    return status
  end

  def fetch_tweets(uid, opts = BASIC_TIMELINE_OPTS, &blk)
    opts = Hashie::Mash.new(opts)
    # prevent repeat fetches
    opts[:since_id] += 1 unless opts[:since_id].nil?
    opts[:max_id] -= 1 unless opts[:max_id].nil?
    opts.merge!( get_identity_hash uid )
    status = nil

    loop do
      status = fetch status, :user_timeline, opts, &blk
      last_tweet = status.last_result
      break if last_tweet.nil?
      # add a :max_id constraint, minus 1
      opts.merge!(:max_id => (last_tweet[:id] - 1))
    end

    return status
  end

  def fetch_tweets_since(uid, since_id, opts = BASIC_TIMELINE_OPTS, &blk)
    new_opts = Hashie::Mash.new(opts)
    new_opts.merge!(since_id: since_id)

    fetch_tweets(uid, new_opts, &blk)
  end

  private 
    def fetch(*args)
      first_arg = args.shift
      # this is UGLY
      if first_arg.is_a?(Symbol) || first_arg.is_a?(String)
      # first arg is something like :user_timeline
        client_foo_name = first_arg
        status_info = init_info_structure
      elsif first_arg.nil? || first_arg.empty?
      # an empty object or nil is being sent in
        status_info = init_info_structure # yuck, not DRY
        client_foo_name = args.shift
      else 
      # status_hash has been resubmitted
        status_info = first_arg
        client_foo_name = args.shift
      end
      
      # collect the results into an Array if no block was given
      status_info[:results] ||= [] unless block_given?

      begin
        results = @client.send(client_foo_name, *args)
      rescue => err
        raise err
 
        # binding.pry
        # status_info[:error_count] += 1
        
        # x = get_rate_limit_seconds(err)
        # if x.is_a?(Fixnum)
        #   puts "#{Time.now}: Sleeping for #{x} seconds"
        #   sleep x
        #   retry
        # else
        #   raise err
        # end
      else
        arr = Array(results).map do |r|
          # increment the info_hash count
          status_info.results_count += 1
          # convert each Twitter::Object into a Hash
          h = r.to_h
          
          # if a block is given, yield it
          if block_given?
            yield h
          else
            status_info[:results] << h
          end

          status_info.last_result = h
        end         

        return status_info

      end
    end


    def init_info_structure
      Hashie::Mash.new(start_time: Time.now, end_time: nil, error_count: 0, results_count: 0, last_result: nil)
    end


    # return either a Fixnum, or an Error class
    def get_rate_limit_seconds(err)
      return err
    end


    # returns a Hash
    def get_identity_hash(val)
      val.is_a?(Fixnum) ? {user_id: val} : {screen_name: val}
    end

##### class methods

  # key is a Hash with proper keys, e.g. :access_token, :access_token_scret
  # returns a single Twitter::Rest::Client
  # if key is already a Twitter::Client, just return it
  def self.initialize_client(key=nil)
    return key if key.is_a?Twitter::REST::Client

    key ||= DEFAULT_KEY_FILE
    key = YAML.load_file(key) if key.is_a?(String)
    key = Hashie::Mash.new(key)

    Twitter::REST::Client.new do |config|
      %w(consumer_key consumer_secret access_token access_token_secret).each do |a|
        config.send "#{a}=", key[a]
      end
    end
  end


  def self.fetch_and_file(output_filename, client_opts, *args)

  end

end