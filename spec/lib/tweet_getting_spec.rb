require 'spec_helper'

describe TwitterGitter do
  describe 'fetching tweets' do

    describe 'return value' do
      it 'should return a Hash'
      describe 'returned Hash' do
        it 'should contain the :last Tweet'
        it 'should contain :start_time'
        it 'should contain :end_time'
        it 'should contain :results_count'
      end
    end

  end
end
