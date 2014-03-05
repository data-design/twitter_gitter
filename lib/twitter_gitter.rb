require "twitter_gitter/version"


require 'twitter'
require 'hashie'
require 'yaml'
# To give objects the :class_attribute convenience
# require 'active_support/core_ext/class'

class TwitterGitter
  DEFAULT_KEY_FILE = ENV['TWITTER_CREDS']

  MAX_BATCH_SIZE_USERS = 100
  MAX_BATCH_SIZE_TWEETS = 200
  BASIC_TIMELINE_OPTS = { 
    trim_user: true, 
    include_rts: true,
    since_id: 1,
    count: MAX_BATCH_SIZE_TWEETS
  }


  attr_reader :client

  def initialize(key=DEFAULT_KEY_FILE)
    @client = TwitterGitter.initialize_client(key)
  end

  def fetch_user(id)
    fetch( :user, id ){ }
  end

  def fetch_users(ids, &blk)
    ids = Array(ids)
    last_user = nil

    ids.each_slice(MAX_BATCH_SIZE_USERS) do |arr|
      last_user = fetch :users, arr, &blk
    end

    return last_user
  end

  def fetch_tweets(uid, opts = BASIC_TIMELINE_OPTS, &blk)
    opts = Hashie::Mash.new(opts)
    opts.merge!( get_identity_hash uid )

    loop do 
      last_tweet = fetch :user_timeline, opts do |tweet|
        yield tweet
      end

      break if last_tweet.nil?
      # add a :max_id constraint
      opts.merge!(:max_id => last_tweet[:id])
    end
  end

  def fetch_tweets_since(uid, since_id, opts = BASIC_TIMELINE_OPTS, &blk)
    new_opts = Hashie::Mash.new(opts)
    new_opts.merge!(since_id: since_id)

    fetch_tweets(uid, new_opts, &blk)
  end

  private 
    def fetch(*args)
      begin
        results = @client.send(*args)
      rescue => err
        raise err
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
          # convert each Twitter::Object into a Hash
          h = r.to_h
          # yield it to the caller
          yield h

          h
        end
        # At the end of the fetching, returning the last element,
        # even if it is nil
        return arr.last
      end
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