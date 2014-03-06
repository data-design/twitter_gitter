require 'spec_helper'
describe TwitterGitter do

# need to set up better fixtures
  describe 'end-to-end', vcr: true do
    subject{ TwitterGitter.new }


    describe '#fetch_user' do
      let(:screen_name){ 'WhiteHouse' }
      it 'returns a single Hash of user data' do
        result = subject.fetch_user(screen_name)
        expect(result[:screen_name]).to eq screen_name
      end
    end

    describe '#fetch_users' do
      let(:screen_names){ Array('a'..'da').map(&:to_s) }
      let(:job){ subject.fetch_users(screen_names) }

      it 'returns an array of users' do
        
        expect( job.results.all?{|h| h.is_a?(Hash)} ).to be true
        expect( job.results.size ).to eq job.results_count 
      end
    end

    describe '#fetch_tweets' do
      let(:screen_name){ 'WhiteHouse' } # assuming account as 3200+ tweets
      let(:job){ subject.fetch_tweets(screen_name) }

      context 'entire batch' do
        it 'should fetch close to 3,200 tweets' do
          expect(job.results.all?{|r| r.is_a?(Hash)})
          expect(job.results_count).to be_within(200).of 3200
        end
      end
  #     context 'entire batch', vcr: true do
  #       it 'should fetch close to 3,200 tweets' do
  #         arr = []
  #         subject.fetch_tweets(screen_name) do |tweet|
  #           arr << tweet
  #         end

  #         expect(arr.size).to be_within(200).of(3200)
  #         # should be no duplicate ids
  #         expect(arr.map{|a| a[:id] }.uniq.size  ).to eq arr.size
  #       end

  #         # tweets collected in chronological order
  #         expect(Time.parse( arr.first[:created_at] ) ).to be > Time.parse( arr.last[:created_at])
  #       end

  #       it 'should return giant results array without block' do
  #         status = subject.fetch_tweets(screen_name)
  #         expect(status.results.count).to eq status.results_count
  #       end
  #     end

  #   context 'using #fetch_tweets_since', skip: true do
  #     let(:since_id){ 436880744007233536 }
  #     # note, this test could quickly go out of date...
  #     it 'should be a limited batch', vcr: true do
  #       status = subject.fetch_tweets_since(screen_name, since_id)
  #       expect(status.results_count).to be < 2000
  #     end

    end
  

  end
end


