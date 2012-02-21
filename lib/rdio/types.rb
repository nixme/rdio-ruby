require 'rash'

module Rdio::Types
  class APIType < Hashie::Rash
    def initialize(client, hash)
      @client = client   # TODO: might not be a great idea?
      super hash
    end
  end

  class Album < APIType; end
  class Artist < APIType; end
  class Label < APIType; end
  class Playlist < APIType; end
  class Track < APIType; end
  class User < APIType; end
  class CollectionAlbum < APIType; end
  class CollectionArtist < APIType; end
  class LabelStation < APIType; end
  class ArtistStation < APIType; end
  class HeavyRotationStation < APIType; end
  class HeavyRotationUserStation < APIType; end
  class ArtistTopSongsStation < APIType; end
  class UserCollectionStation < APIType; end


  # Mapping from 'type' field values to Rdio::Types classes.
  # See http://developer.rdio.com/docs/read/rest/types
  API_NAME_TO_CLASS = {
    'a'   => Album,
    'r'   => Artist,
    'l'   => Label,
    'p'   => Playlist,
    't'   => Track,
    's'   => User,
    'al'  => CollectionAlbum,
    'rl'  => CollectionArtist,
    # 'l'  => LabelStation,
    'rr'  => ArtistStation,
    'h'   => HeavyRotationStation,
    'e'   => HeavyRotationUserStation,
    'tr'  => ArtistTopSongsStation,
    'c'   => UserCollectionStation
  }

  def wrap_result(client, result)
    case result
    when Hash
      if klass = API_NAME_TO_CLASS[result['type']]
        klass.new(client, result)
      else
        result
      end
    when Array
      result.map { |item| wrap_result(client, item) }
    else
      result
    end
  end
end
