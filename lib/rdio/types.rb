%w[
 base album artist label track playlist user collection_album collection_artist
 artist_station heavy_rotation_station heavy_rotation_user_station
 artist_top_songs_station user_collection_station get_results search_results
 playlists_result activity_stream activity
].each do |type|
  require "rdio/types/#{type}"
end

module Rdio
  module Types

    # Mapping from 'type' field values in API responses to Rdio::Types classes.
    # See http://developer.rdio.com/docs/read/rest/types
    #
    # LabelStation is skipped as the docs assign it the same type identifier as
    # Label and there are no API methods that use it.
    #
    API_IDENTIFIER_TO_CLASS = {
      'a'   => Album,
      'r'   => Artist,
      'l'   => Label,
      'p'   => Playlist,
      't'   => Track,
      's'   => User,
      'al'  => CollectionAlbum,
      'rl'  => CollectionArtist,
      'rr'  => ArtistStation,
      'h'   => HeavyRotationStation,
      'e'   => HeavyRotationUserStation,
      'tr'  => ArtistTopSongsStation,
      'c'   => UserCollectionStation
    }

    def self.unwrap_params(params)
      Hash[
        params.map do |name, value|
          [
            name,
            case value
            when Base  then value.key
            when Array then value.join(',')
            else            value
            end
          ]
        end
      ]
    end

    def self.autowrap(result, client)
      case result
      when Hash
        type = result['type']
        klass = API_IDENTIFIER_TO_CLASS[type]
        raise UnknownType unless klass
        klass.new(result, client)
      when Array
        result.map { |item| autowrap(item, client) }
      else
        result
      end
    end
  end
end
