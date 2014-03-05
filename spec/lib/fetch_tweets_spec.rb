require 'spec_helper'

describe TwitterGitter do

  describe '#fetch_tweets' do
    let(:client){ Twitter::REST::Client.new }
    

    describe 'params sent to API call' do
      subject{ TwitterGitter.new(client) }
      before do
        allow(client).to receive(:user_timeline).with(a_kind_of(Hash)){ [] }
      end

      context 'differentiating between user_id and screen_name' do
        it 'should interpret Fixnum as :user_id' do
          subject.fetch_tweets(42){ }
          expect(client).to have_received(:user_timeline).with(hash_including(:user_id => 42))
        end

        it 'should interpret String as :screen_name' do
          subject.fetch_tweets("life"){ }
          expect(client).to have_received(:user_timeline).with(hash_including(:screen_name => 'life'))
        end

      end

      context 'default statuses/user_timeline params' do
        it 'should ask for 200 trimmed tweets' do
          subject.fetch_tweets("guy"){ }
          expect(client).to have_received(:user_timeline).with(
            hash_including(:screen_name => 'guy', count: 200, trim_user: true)
          )
        end

        it 'should allow attributes to be overridden' do
          subject.fetch_tweets('guy', count: 10, trim_user: false, since_id: 909 ){}
          expect(client).to have_received(:user_timeline).with(
            # since_id is always incremented
            hash_including(:since_id => 910, count: 10, trim_user: false)
          )
        end

        describe '#fetch_tweets_since variation' do
          it 'should allow for second argument to be Fixnum representing :since_id' do
            subject.fetch_tweets_since('guy', 777){ }
            # since_id is always incremented
            expect(client).to have_received(:user_timeline).with(
              hash_including(since_id: 778)
            )
          end
        end        
      end

    end    
  


    # need to set up better fixtures
    describe 'end-to-end', vcr: true do
      subject{ TwitterGitter.new }
      let(:screen_name){ 'WhiteHouse' } # assuming account as 3200+ tweets

      context 'entire batch' do
        it 'should fetch close to 3,200 tweets', vcr: true do
          arr = []
          subject.fetch_tweets(screen_name) do |tweet|
            arr << tweet
          end

          expect(arr.size).to be_within(200).of(3200)
          # should be no duplicate ids
          expect(arr.map{|a| a[:id] }.uniq.size  ).to eq arr.size

          # tweets collected in chronological order
          expect(Time.parse( arr.first[:created_at] ) ).to be > Time.parse( arr.last[:created_at])
        end
      end

      context 'using #fetch_tweets_since' do
        let(:since_id){ 436880744007233536 }
        # note, this test could quickly go out of date...
        it 'should be a limited batch', vcr: true do
          arr = []
          subject.fetch_tweets_since(screen_name, since_id) do |tweet|
            arr << tweet
          end

          expect(arr.size).to be < 2000
        end
      end
    end

  end
end