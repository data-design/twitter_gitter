require 'spec_helper'

describe TwitterGitter do

  describe '#fetch_tweets' do
    let(:client){ Twitter::REST::Client.new }
    subject{ TwitterGitter.new(client) }

    describe 'params sent to API call' do
      before do
        allow(client).to receive(:user_timeline).with(a_kind_of(Hash)){ [] }
      end

      context 'differentiating between user_id and screen_name' do
        it 'should interpret Fixnum as :user_id' do
          subject.fetch_tweets(42){ }
          expect(client).to have_received(:user_timeline).with(hash_including(:user_id => 42))
        end
      end

      context 'default statuses/user_timeline params' do
        it 'should ask for 200 trimmed tweets' do
          # subject.fetch_tweets()
          # expect(client)
        end
      end

    end    
  end


end