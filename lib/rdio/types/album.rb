module Rdio
  module Types

    # A recording, usually an album but often a single, EP or compilation.
    #
    class Album < Base
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
              :duration
      extra   :iframeUrl,
              :isCompilation,
              :label,
              :bigIcon,
              :releaseDateISO


      def tracks
        @tracks ||= fetch_collection(:trackKeys, Track)
      end

      def artist_object
        @artist_object ||= fetch_object(:artistKey, Artist)
      end
    end
  end
end
