$:.unshift File.dirname(__FILE__)

require 'httparty'
require 'uri'

module MetaSpotify

  API_VERSION = 'v1'

  class Base
    include HTTParty
    base_uri 'https://api.spotify.com'

    attr_reader :name, :uri, :popularity

    def self.uri_regex
      nil
    end

    def self.search(string, opts={})
      item_name = self.name.downcase.gsub(/^.*::/,'')
      query = {:q => string}
      query[:page] = opts[:page].to_s if opts.has_key? :page
      result = get("/#{API_VERSION}/search?type=#{item_name}",
        :query => query,
        :format => :json,
        :query_string_normalizer => self.method(:normalize))
      raise_errors(result)
      result = result[item_name+'s']
      items = []
      result['items'].each do |item|
        items << self.new(item)
      end
      return { :items => items,
               :limit => result["limit"].to_i,
               :next => result["next"].to_i,
               :offset => result["offset"].to_i,
               :total => result["total"].to_i
              }
    end

    def self.lookup(id, opts={})
      item_name = self.name.downcase.gsub(/^.*::/,'')
      query = {}
      query[:extras] = opts[:extras] if opts.has_key? :extras
      result = get("/#{API_VERSION}/#{item_name}s/#{id}",:query => query, :format => :json)
      raise_errors(result)
      case item_name
      when "artist"
        return Artist.new(result)
      when "album"
        return Album.new(result)
      when "track"
        return Track.new(result)
      end
    end

    def spotify_id
      if uri
        uri[self.class.uri_regex, 1]
      else
        nil
      end
    end

    private

    def self.raise_errors(response)
      case response.code
      when 400
        raise BadRequestError.new('400 - The request was not understood')
      when 403
        raise RateLimitError.new('403 - You are being rate limited, please wait 10 seconds before requesting again')
      when 404
        raise NotFoundError.new('404 - That resource could not be found.')
      when 406
        raise BadRequestError.new('406 - The requested format isn\'t available')
      when 500
        raise ServerError.new('500 - The server encountered an unexpected problem')
      when 502
        raise ServerError.new('502 - The API internally received a bad response')
      when 503
        raise ServerError.new('503 - The API is temporarily unavailable')
      end
    end

    def self.normalize(query)
      stack = []
      query.each do |key, value|
        stack.push "#{key}=#{URI.encode_www_form_component value}"
      end
      stack.join("&")
    end

  end

  class MetaSpotifyError < StandardError
    attr_reader :data

    def initialize(data)
      @data = data
      super
    end
  end
  class URIError < MetaSpotifyError; end
  class RateLimitError < MetaSpotifyError; end
  class NotFoundError < MetaSpotifyError; end
  class BadRequestError < MetaSpotifyError; end
  class ServerError < MetaSpotifyError; end
end

require 'meta-spotify/artist'
require 'meta-spotify/track'
require 'meta-spotify/album'
require 'meta-spotify/version'
