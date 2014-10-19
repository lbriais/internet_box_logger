#-------------------------------------------------------------------------------
#  
#
# Copyright (c) 2014 L.Briais under MIT license
# http://opensource.org/licenses/MIT
#-------------------------------------------------------------------------------

require 'spec_helper'
require 'internet_box_logger/freebox_v5'

#describe EasyAppHelper::Core::Config do
describe "When created from real measurements" do
  subject {InternetBoxLogger::FreeboxV5.etl}

  it "should not have a #created_at value" do
    expect( subject.created_at).to be_nil
  end

  it "should not have been #saved? automatically" do
    expect( subject.saved?).to be_falsey
  end

end