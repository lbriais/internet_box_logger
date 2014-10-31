require 'spec_helper'

describe InternetBoxLogger::Parsers do

  it 'should have 1 parser' do
    expect(subject.list.length == 1).to be_truthy

  end
end


