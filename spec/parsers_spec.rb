require 'spec_helper'

describe InternetBoxLogger::Parsers do

  it 'should have 1 parser' do
    expect(subject[].length == 1).to be_truthy
  end


  InternetBoxLogger::Parsers[].each do |current_parser|

    context "when testing '#{current_parser}' parser" do

      subject {
        s = Object.new
        s.extend current_parser
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

      it 'should have many up/down documents and one info' do
        subject.get_box_data
        docs = subject.as_es_documents
        up, down, info, unknown = 0, 0, 0, 0
        docs.each do |doc|
          case doc[:type]
            when 'up'
              up += 1
            when 'down'
              down += 1
            when :info
              info += 1
            else
              unknown += 1
          end
        end
        expect(up == down).to be_truthy
        expect(info == 1).to be_truthy
        expect(unknown == 0).to be_truthy
      end


    end
  end

end
