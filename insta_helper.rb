require 'httparty'
require 'json'

module Media
  def self.search params = {} 
    media_fetcher = MediaFetcher.new
    media_fetcher.search_media params
  end

  class MediaFetcher
    def search_media params = {} 
      url = build_url params 
      headers = build_header

      media = HTTParty.get url, headers
      media_to_granuals media['data']
    end

    private
    def build_url params = {}
      url = "https://api.instagram.com/v1/media/search?" + 
      "lat="  + params['lat'] +
      "&lng=" + params['lng'] +
      "&max_timestamp=" + params['time'] +
      "&distance=" + "200" +
      "&access_token=" + 
      ENV['INSTAGRAM_ACCESS_TOKEN']
    end

    def build_header
      {
        "User-Agent" => "request"
      }
    end

    def location media
      {
        latitude:  media['location']['latitude'],
        longitude: media['location']['longitude']
      }
    end

    def images media
      if media['type'] == 'image'
        {
          thumb:    media['images']['thumbnail']['url'],
          low_res:  media['images']['low_resolution']['url'],
          high_res: media['images']['standard_resolution']['url']
        }
      else
        {
          low_resolution:      media['videos']['low_resolution']['url'],
          standard_resolution: media['videos']['high_resolution']['url']
        }
      end
    end

    def caption media
      if media['caption']
        media['caption']['text']
      else
        ""
      end
    end
    
    def media_to_granual media
      return {
        type:       media['type'],
        created_at: media['created_time'],
        source:     'instagram',
        link:       media['link'],
        author:     media['user']['username'],
        location:   location(media),
        images:     images(media),
        caption:    caption(media),
        hashtags:   media['tags']
      }
    end
    
    def media_to_granuals medias
      medias.map do |media|
        media_to_granual media
      end
    end
  end
end