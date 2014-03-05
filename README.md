# TwitterGitter

A quick wrapper around the excellent [sferik/twitter Ruby gem](https://github.com/sferik/twitter).

Basically, hides the details of paginating for a user's entire timeline or for getting batches of user profiles. Only works with one Twitter app/user as per Twitter's guidelines, so there is (to be implemented) a simplistic handling of rate-limits (i.e. sleep until Twitter says you can fetch again).

However, the main purpose of this gem is as a teaching exercise for the [Guide to Boring Data Design with Ruby on Rails](https://github.com/data-design/rails-guide), by Dan Nguyen, and to be completed in the far far future. It's more of a demonstration of how to do test-driven development using test doubles and mocks, via the excellent [RSpec 3.0.0beta](https://www.relishapp.com/rspec/rspec-expectations/v/3-0/docs) and the [amazing vcr gem](https://github.com/vcr/vcr) for fixtures.

## Usage

~~~ruby
require 'twitter_gitter'
client = TwitterGitter.new('credentials.yml')

# Or, if ENV['TWITTER_CREDS'] points to a file:
client = TwitterGitter.new
~~~

## Fetch user profiles

~~~ruby
# fetch a single user (not much different than plain Twitter::REST::Client)
user_obj = client.fetch_user('WhiteHouse')
# user_obj.class is a plain old Ruby Hash, rather than a Twitter::User

# fetch a batch of users
user_ids = Array(1..1001).map(&:to_s)
# screen_names of '1' through '1001'
# #fetch_users does the work of splitting user_ids into 100-element requests
arr = []
client.fetch_users() do |user|
  # each Twitter::User object is converted to a hash and yielded to the end-user
  # for processing
  arr << user
end
~~~


## Fetch tweets

Fetch as many tweets as possible (up to around 3,200) for a given user

~~~ruby
tweets = []
client.fetch_tweets('WhiteHouse') do |tweet|
  tweets << tweet
end
~~~



TODO: Show how handling of rate-limit can be configured


## Installation

Add this line to your application's Gemfile:

    gem 'twitter_gitter', github: 'data-design/twitter_gitter'

And then execute:

    $ bundle

It is currently not available on Rubygems, as it is meant to be a tutorial on basic Ruby programming and testing via mocks.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
