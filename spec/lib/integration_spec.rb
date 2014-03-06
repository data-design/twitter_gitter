require 'spec_helper'
describe TwitterGitter do

# need to set up better fixtures
  describe 'integration' do
    subject{ TwitterGitter.new }


    describe '#fetch_user', vcr: true do
      let(:screen_name){ 'WhiteHouse' }
      it 'returns a single Hash of user data' do
        result = subject.fetch_user(screen_name)
        expect(result[:screen_name]).to eq screen_name
      end
    end

    describe '#fetch_users', vcr: { cassette_name: 'users_batch', :record => :new_episodes } do
      let(:screen_names){ Array('a'..'da').map(&:to_s) }
      let(:job){ subject.fetch_users(screen_names)  }
      it 'returns an array of users' do
        expect( job.results.all?{|h| h.is_a?(Hash)} ).to be true
        expect( job.results.size ).to eq job.results_count 
      end

      context 'block passed in' do
        it 'yield for each retrieved user' do 
          expect{|b| subject.fetch_users(screen_names, &b) }.to yield_control.at_most(screen_names.count).times
        end
      end
    end

    describe '#fetch_tweets', vcr: { cassette_name: 'fetch_tweets', :record => :new_episodes }  do
      let(:screen_name){ 'WhiteHouse' } # assuming account as 3200+ tweets
      let(:job){ subject.fetch_tweets(screen_name) }

      it 'should fetch close to 3200 tweets' do
        expect(job.results.all?{|r| r.is_a?(Hash)})
        expect(job.results_count).to be_within(200).of 3200
      end

      it 'should fetch tweets in reverse chronological order' do 
        expect(Time.parse( job.results.first[:created_at] ) ).to be > Time.parse( job.results.last[:created_at])
      end

      context 'block passed in' do
        it 'yield for each retrieved Tweet' do 
          expect{|b| subject.fetch_tweets(screen_name, &b) }.to yield_control.at_least(3200).times
        end
      end
    end

    describe '#fetch_tweets_since',  vcr: { cassette_name: 'fetch_tweets_since', :record => :new_episodes } do
      let(:screen_name){ 'WhiteHouse' } # assuming account as 3200+ tweets
      let(:since_id){ 436880744007233536 }
      let(:job){ subject.fetch_tweets_since(screen_name, since_id) }
      # note, this test could quickly go out of date...
      it 'should be a limited batch', vcr: true do
        expect(job.results_count).to be < 2000
      end
    end
  

  end
end


