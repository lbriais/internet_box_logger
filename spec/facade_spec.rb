require 'spec_helper'


describe InternetBoxLogger::Facade do

  subject {InternetBoxLogger::Facade}

  it 'should include a parser of the box_type specified in the constructor' do
    parser = InternetBoxLogger::Parsers::FreeboxV5
    facade = subject.new(parser)
    expect( facade.respond_to? :get_box_data).to be_truthy
  end

end