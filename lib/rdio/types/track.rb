module Rdio
  module Types

    # A song.
    #
    class Track < Base
      default :name,
              :artist,
              :album,
              :albumKey,
              :albumUrl,
              :artistKey,
              :artistUrl,
              :length,
              :duration,
              :isExplicit,
              :isClean,
              :url,
              :baseIcon,
              :albumArtist,
              :albumArtistKey,
              :canDownload,
              :canDownloadAlbumOnly,
              :canStream,
              :canTether,
              :canSample,
              :price,
              :shortUrl,
              :embedUrl,
              :key,
              :icon,
              :trackNum
      extra   :isInCollection,
              :isOnCompilation,
              :iframeUrl,
              :playCount,
              :bigIcon


      def album_object
        @album_object ||= fetch_object(:albumKey, Album)
      end

      def artist_object
        @artist_object ||= fetch_object(:artistKey, Artist)
      end

      def album_artist_object
        @album_artist_object ||= fetch_object(:albumArtistKey, Artist)
      end
    end
  end
end
