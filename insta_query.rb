require 'httparty'
# require 'json'

module InstaQuery

  def self.search params = {} 
    insta_search = InstaSearch.new params
    insta_search.request
  end

  class InstaSearch
    include HTTParty
    base_uri 'https://api.instagram.com/v1/media/search?'
    format    :json

    attr_reader :access_token, 
                :headers, 
                :lat, 
                :lng, 
                :noonLocale, 
                :startingTimestamp,
                :utc_offset, 
                :timestamp_spread

    def initialize params = {}

      @access_token       = ENV['INSTAGRAM_ACCESS_TOKEN']
      @headers            = { 'User-Agent' => 'request'}
      @lat                = params['lat']
      @lng                = params['lng']
      @noonLocale         = params['time']
      @startingTimestamp  = noonLocale.to_i - 43200
      @utc_offset         = params['utc_offset']
      @timestamp_spread   = 14400 # this is 4 hours in seconds

    end

    def request

      instagrams = []

      6.times do |i|

        min_timestamp = startingTimestamp + (timestamp_spread * i)
        max_timestamp = min_timestamp + timestamp_spread

        url_params    = "lat=" + lat + "&" +
                        "lng=" + lng + "&" +
                        "min_timestamp=" + min_timestamp.to_s + "&" +
                        "max_timestamp=" + max_timestamp.to_s + "&" +
                        "distance=" + "500" + "&" +
                        "count=" + "15" + "&" +
                        "access_token=" + access_token

        response = self.class.get(url_params, :headers => headers)

        instagrams += response.parsed_response['data'].map { |instagram| instagram_to_granule instagram }

      end

      filter_instas instagrams

    end

    private

    def filter_instas instagrams

      instagrams.uniq { |instagram| instagram[:images] }

    end

    def instagram_to_granule instagram
      return {
        type:       instagram['type'],
        created_at: instagram['created_time'],
        source:     'instagram',
        link:       instagram['link'],
        author:     instagram['user']['username'],
        location:   location(instagram),
        images:     images(instagram),
        caption:    caption(instagram),
        hashtags:   instagram['tags']
      }
    end

    def location instagram
      if instagram['location']
        {
          latitude:  instagram['location']['latitude'],
          longitude: instagram['location']['longitude']
        }
      else
        {
          latitude:  lat,
          longitude: lng
        }
      end
    end

    def images instagram
      { 
        thumb:    instagram['images']['thumbnail']['url'],
        low_res:  instagram['images']['low_resolution']['url'],
        high_res: instagram['images']['standard_resolution']['url'] 
      }
    end

    def caption instagram
      if instagram['caption']
        instagram['caption']['text']
      else
        ""
      end
    end
    
  end
end