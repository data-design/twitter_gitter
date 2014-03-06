require 'spec_helper'

describe TwitterGitter do

  describe '#fetch_tweets' do
    let(:client){ Twitter::REST::Client.new }
    

    describe 'params sent to API call' do
      subject{ TwitterGitter.new(client) }
      before do
        allow(client).to receive(:user_timeline).with(a_kind_of(Hash)){ Hash.new }
      end

      context 'differentiating between user_id and screen_name' do
        it 'should interpret Fixnum as :user_id' do
          subject.fetch_tweets(42)
          expect(client).to have_received(:user_timeline).with(hash_including( :user_id => 42 ))
        end

        it 'should interpret String as :screen_name' do
          subject.fetch_tweets("life")
          expect(client).to have_received(:user_timeline).with(hash_including(:screen_name => 'life'))
        end

      end

      context 'default statuses/user_timeline params' do
        it 'should ask for 200 trimmed tweets' do
          subject.fetch_tweets("guy")
          expect(client).to have_received(:user_timeline).with(
            hash_including(:screen_name => 'guy', count: 200, trim_user: true)
          )
        end

        it 'should allow attributes to be overridden' do
          subject.fetch_tweets('guy', count: 10, trim_user: false, since_id: 909 )
          expect(client).to have_received(:user_timeline).with(
            # since_id is always incremented
            hash_including(:since_id => 910, count: 10, trim_user: false)
          )
        end

        describe '#fetch_tweets_since variation' do
          it 'should allow for second argument to be Fixnum representing :since_id' do
            subject.fetch_tweets_since('guy', 777)
            # since_id is always incremented
            expect(client).to have_received(:user_timeline).with(
              hash_including(since_id: 778)
            )
          end
        end        
      end

    end    
  




  end
end