module MetaSpotify
  class Track < MetaSpotify::Base
    attr_reader :album, :artists, :track_number, :duration_ms,
                :available_markets, :explicit, :popularity,
                :preview_url, :type, :uri, :href, :id

    def initialize(hash)
      @name = hash['name']
      @href = hash['href'] if hash.has_key? 'href'
      @popularity = hash['popularity'].to_f if hash.has_key? 'popularity'

      if hash.has_key? 'artists'
        @artists = []
        hash['artists'].each { |a| @artists << Artist.new(a) }
      end

      @album = Album.new(hash['album']) if hash.has_key? 'album'
      @track_number = hash['track_number'].to_i if hash.has_key? 'track_number'
      @duration_ms = hash['duration_ms'].to_f if hash.has_key? 'duration_ms'
      @id = hash['id'] if hash.has_key? 'id'
      @type = hash['type'] if hash.has_key? 'type'
      @genres = hash['genres'] if hash.has_key? 'genres'
      @external_urls = hash['external_urls'] if hash.has_key? 'external_urls'
      @external_ids = hash['external_ids'] if hash.has_key? 'external_ids'

      @available_markets = hash.fetch('available_markets', [])
    end

    def http_uri
      external_urls['spotify']
    end

    def isrc_id
      external_ids['isrc']
    end
  end
end
