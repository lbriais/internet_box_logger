require 'spec_helper'

describe InternetBoxLogger::Parsers::FreeboxV5 do

  subject {
    s = Object.new
    class << s
      include InternetBoxLogger::Parsers::FreeboxV5
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
    subject.get_box_data
    puts subject.attributes.to_yaml
  end

end