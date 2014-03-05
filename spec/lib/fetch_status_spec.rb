require 'spec_helper'

describe TwitterGitter do
  # mock client result  
    describe ':fetch return value' do
      it 'should contain the :last_result'
      it 'should contain :start_time'
      it 'should contain :end_time'
      it 'should contain :results_count'

      context 'when block is given' do
        it 'should have :results be nil'
      end

      context 'when no block is given' do
        it 'should have :results contain Array of results'
      end

    end

  end
end
