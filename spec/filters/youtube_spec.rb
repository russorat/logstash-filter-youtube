require 'spec_helper'
require "logstash/filters/youtube"

describe LogStash::Filters::Youtube do
  describe "Get video information" do
    let(:config) do <<-CONFIG
      filter {
        youtube {
          api_key => "<YOUR API KEY>"
        }
      }
    CONFIG
    end

    sample("message" => "2U-DdpQI_8Q") do
      expect(subject).to include("youtube")
      expect(subject['youtube']).to include('id')
      expect(subject['youtube']['id']).to eq('2U-DdpQI_8Q')
    end
  end
end
