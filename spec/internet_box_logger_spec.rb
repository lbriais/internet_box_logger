require 'spec_helper'


describe InternetBoxLogger do

  subject {InternetBoxLogger}

  it 'should not accept invalid parsers' do
    expect{ subject.get_box(:stupid)}.to raise_error
  end

  it 'should accept any valid parser' do
    InternetBoxLogger::Parsers.list.each do |parser|
      expect{ subject.get_box(parser)}.not_to raise_error
    end

  end

  it 'should include a parser of the box_type specified in the constructor' do
    parser = InternetBoxLogger::Parsers::FreeboxV5
    box = subject.get_box(parser)
    expect( box.respond_to? :get_box_data).to be_truthy
  end

end