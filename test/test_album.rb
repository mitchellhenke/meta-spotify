require 'helper'

class TestAlbum < Test::Unit::TestCase
  context "an album with territories" do
    setup do
      @album = MetaSpotify::Album.new('name' => 'test', 'available_markets' => ['DE'])
      @worldwide_album = MetaSpotify::Album.new('name' => 'test', 'availability' => { 'territories' => 'worldwide' })
    end
    should "be available in DE" do
      assert @album.is_available_in?('DE')
    end
    should "not be available in UK" do
      assert @album.is_not_available_in?('UK')
    end
  end

  context "searching for an album name" do
    setup do
      FakeWeb.register_uri(:get,
                           "http://ws.spotify.com/search/1/album?q=foo",
                           :body => fixture_file("album_search.xml"))
      @results = MetaSpotify::Album.search('foo')
    end
    should "return a list of results and search meta" do
      assert_kind_of Array, @results[:albums]

      album = @results[:albums].first
      assert_kind_of MetaSpotify::Album, album
      assert_equal "Foo Foo", album.name
      assert_equal 0.29921, album.popularity
      assert_equal '7KXRgAg4K6eXjlYIIXzt3T', album.spotify_id
      assert_equal 'http://open.spotify.com/album/7KXRgAg4K6eXjlYIIXzt3T', album.http_uri

      query = @results[:query]
      assert_equal 1, query[:start_page]
      assert_equal 'request', query[:role]
      assert_equal "foo", query[:search_terms]

      assert_equal 100, @results[:items_per_page]
      assert_equal 0, @results[:start_index]
      assert_equal 6, @results[:total_results]
    end
  end

  context "looking up a album" do
    setup do
      FakeWeb.register_uri(:get,
                           "https://api.spotify.com/v1/albums/#{ALBUM_ID}",
                           :body => fixture_file("album.json"))
      @result = MetaSpotify::Album.lookup(ALBUM_ID)
    end
    should "fetch an album and return an album object" do
      assert_kind_of MetaSpotify::Album, @result
      assert_equal "Watch The Throne", @result.name
      assert_equal ALBUM_ID, @result.id
      assert_equal "2011-08-08", @result.release_date
      assert_equal "00602527809083", @result.upc
      assert_equal 'https://open.spotify.com/album/2P2Xwvh2xWXIZ1OWY9S9o5', @result.http_uri
    end
    should "create an artist object for that album" do
      assert_kind_of Array, @result.artists
      assert_kind_of MetaSpotify::Artist, @result.artists.first
      assert_equal 'JAY Z', @result.artists.first.name
      assert_equal "spotify:artist:3nFkdlSjzX9mRTtwJOzDYB", @result.artists.first.uri
      assert_kind_of MetaSpotify::Track, @result.tracks.first
      assert_equal 'No Church In The Wild', @result.tracks.first.name
    end
  end

  context "looking up an album with just an upc code" do
    setup do
      FakeWeb.register_uri(:get,
                           "http://ws.spotify.com/lookup/1/?uri=#{CGI.escape ALBUM_ONE_UPC_URI}",
                           :body => fixture_file("album_one_upc.xml"))
      @result = MetaSpotify::Album.lookup(ALBUM_ONE_UPC_URI)
    end
    should "fetch an album and return an album object" do
      assert_kind_of MetaSpotify::Album, @result
      assert_equal "Aleph", @result.name
      assert_equal ALBUM_ONE_UPC_URI, @result.uri
      assert_equal "2013", @result.released
      assert_equal "825646397471", @result.upc
      assert_equal '3MiiF9utmtGnLVITgl0JP7', @result.spotify_id
      assert_equal 'http://open.spotify.com/album/3MiiF9utmtGnLVITgl0JP7', @result.http_uri
    end
  end
end
