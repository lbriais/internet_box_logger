require 'spec_helper'

describe InternetBoxLogger::Parsers::FreeboxV5Parser do

  subject {
    s = Object.new
    class << s
      include InternetBoxLogger::Parsers::FreeboxV5Parser
    end
    s
  }

  it 'should parse an url' do
    expect{ subject.get_box_data}.not_to raise_error
  end

  it 'should feed attributes' do
    subject.get_box_data
    expect(subject.attributes.nil?).to be_falsey
    expect(subject.attributes.empty?).to be_falsey
  end

  it 'should use all regexp during parsing'  do
    expect(subject.get_box_data).not_to be_nil
  end

  it 'should export data as an array' do
    subject.get_box_data
    expect(subject.as_es_documents is_a? Array).to be_truthy
  end

end