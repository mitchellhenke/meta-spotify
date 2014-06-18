module MetaSpotify
  class Artist < MetaSpotify::Base
    attr_reader :genres, :href, :id, :external_urls,
                :popularity, :type, :uri

    def initialize(hash)
      @name = hash['name']
      @popularity = hash['popularity'].to_f if hash.has_key? 'popularity'
      @uri = hash['uri'] if hash.has_key? 'uri'
      @href = hash['href'] if hash.has_key? 'href'
      @id = hash['id'] if hash.has_key? 'id'
      @genres = hash['genres'] if hash.has_key? 'genres'
      @type = hash['type'] if hash.has_key? 'type'
    end

    def http_uri
      external_urls['spotify']
    end
  end
end
