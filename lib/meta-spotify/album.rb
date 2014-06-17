module MetaSpotify
  class Album < MetaSpotify::Base

    def self.uri_regex
      /^spotify:album:([A-Za-z0-9]+)$/
    end

    attr_reader :release_date, :artists, :available_markets, :tracks, :upc,
                :id, :genres, :type, :album_type, :external_urls, :href, :uri,
                :external_ids

    def initialize(hash)
      @name = hash['name']
      @popularity = hash['popularity'].to_f if hash.has_key? 'popularity'
      if hash.has_key? 'artists'
        @artists = []
        hash['artists'].each { |a| @artists << Artist.new(a) }
      end
      if hash.has_key? 'tracks'
        @tracks = []
        hash['tracks']['items'].each { |a| @tracks << Track.new(a) }
      end
      @release_dated = hash['release_date'] if hash.has_key? 'release_date'
      @href = hash['href'] if hash.has_key? 'href'
      @uri = hash['uri'] if hash.has_key? 'uri'
      @id = hash['id'] if hash.has_key? 'id'
      @type = hash['type'] if hash.has_key? 'type'
      @album_type = hash['album_type'] if hash.has_key? 'album_type'
      @genres = hash['genres'] if hash.has_key? 'genres'
      @external_urls = hash['external_urls'] if hash.has_key? 'external_urls'
      @external_ids = hash.fetch('external_ids', [])

      @available_markets = hash.fetch('available_markets', [])
    end

    def is_available_in?(territory)
      @available_markets.include?(territory.upcase)
    end

    def is_not_available_in?(territory)
      !is_available_in?(territory)
    end

    def http_uri
      external_urls['spotify']
    end

    def upc
      external_ids['upc']
    end

  end
end
