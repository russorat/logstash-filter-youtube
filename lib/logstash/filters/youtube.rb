require "logstash/filters/base"
require "logstash/namespace"
require "ftw"
require "json"
require "socket"

class LogStash::Filters::Youtube < LogStash::Filters::Base

  config_name "youtube"

  # Api key for read only access
  # https://developers.google.com/console/help/new/#generatingdevkeys
  config :api_key, :validate => :string, :required => true
  # Event field where YouTube video id is stored
  config :source, :validate => :string, :default => 'message'
  # Event key where resulting video data should be stored
  config :target, :validate => :string, :default => 'youtube'
  # Parts of video to return. For list of options, see:
  # https://developers.google.com/youtube/v3/docs/videos/list
  config :parts, :valadate => :string, :default => 'id,snippet,statistics'

  # Should not change unless major change to youtube api
  config :service_name, :validate => :string, :default => 'youtube'
  config :api_version, :validate => :string, :default => 'v3'

  # The application name and version for calling the YouTube API
  config :app_name, :validate => :string, :default => 'logstash-filter-youtube'
  config :app_version, :validate => :string, :default => '1.0.0'

  public
  def register
    require 'google/api_client'
    require 'trollop'
  end # def register

  public
  def filter(event)
    return unless filter?(event)
    return unless event[@source]
    return if event[@source].empty?
    begin
      client, youtube = get_service

      video_response = client.execute(
        :api_method => youtube.videos.list,
        :parameters => {
          :part => @parts,
          :id => event[@source].strip()
        }
      )

      #this will only have 0 or 1 items
      video_response.data.items.each do |video_result|
        event[@target] = video_result.to_hash
        filter_matched(event)
      end
    rescue Google::APIClient::TransmissionError => e
      @logger.error(e.result.body)
    rescue StandardError => e
      @logger.error(e)
    end
  end # def filter

  private
  def get_service
    client = Google::APIClient.new(
      :key => @api_key,
      :authorization => nil,
      :application_name => @app_name,
      :application_version => @app_version
    )
    youtube = client.discovered_api(@service_name, @api_version)

    return client, youtube
  end

end # class LogStash::Filters::YouTube
