require 'spec_helper'

describe 'Hello World' do 
  it 'should say hello' do
    expect('hello').to be_a String
  end
end


describe 'Hello TwitterGitter' do
  it 'should be a Class' do
    expect(TwitterGitter).to be_a Class
  end
end