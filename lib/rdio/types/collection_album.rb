module Rdio
  module Types

    # An album in a user's collection. It will be basically the same as the
    # equivalent Album object except that it will only contain the subset of
    # tracks from the album that the user has in their collection.
    #
    class CollectionAlbum < Base
      default :name,
              :icon,
              :baseIcon,
              :url,
              :artist,
              :artistUrl,
              :isExplicit,
              :isClean,
              :length,
              :artistKey,
              :trackKeys,
              :price,
              :canStream,
              :canSample,
              :canTether,
              :shortUrl,
              :embedUrl,
              :displayDate,
              :key,
              :releaseDate,
              :duration,
              :userKey,
              :userName,
              :albumKey,
              :albumUrl,
              :collectionUrl,
              :itemTrackKeys
      extra   :iframeUrl,
              :userGender,
              :isCompilation,
              :label,
              :releaseDateISO,
              :bigIcon


      def tracks
        @tracks ||= fetch_collection(:trackKeys, Track)
      end

      def whole_album_tracks
        @whole_album_tracks ||= fetch_collection(:itemTrackKeys, Track)
      end

      def artist_object
        @artist_object ||= fetch_object(:artistKey, Artist)
      end

      def user_object
        @user_object ||= fetch_object(:userKey, User)
      end

      def album_object
        @album_object ||= fetch_object(:albumKey, Album)
      end
    end
  end
end
