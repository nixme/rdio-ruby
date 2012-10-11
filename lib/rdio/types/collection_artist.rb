module Rdio
  module Types

    # An artist in a user's collection. It will be basically the same as the
    # equivalent Artist except it only contains the albums that are in the
    # user's collection.
    #
    class CollectionArtist < Base
      default :name,
              :key,
              :url,
              :length,
              :icon,
              :baseIcon,
              :hasRadio,
              :shortUrl,
              :radioKey,
              :topSongsKey,
              :userKey,
              :userName,
              :artistKey,
              :artistUrl,
              :collectionUrl
      extra   :count,
              :albumCount


      def station
        @station ||= fetch_object(:radioKey, ArtistStation)
      end
      alias :radio :station

      def top_songs_station
        @top_songs_station ||= fetch_object(:topSongsKey, ArtistTopSongsStation)
      end
      alias :top_songs_radio :top_songs_station

      def user_object
        @user_object ||= fetch_object(:userKey, User)
      end

      def artist_object
        @artist_object ||= fetch_object(:artistKey, Artist)
      end
    end
  end
end
