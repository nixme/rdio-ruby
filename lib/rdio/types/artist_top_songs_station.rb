module Rdio
  module Types

    # An artist's station.
    #
    class ArtistTopSongsStation < Base
      default :key,
              :topSongsKey,   # Equivalent to :key
              :baseIcon,
              :tracks,
              :artistUrl,
              :radioKey,
              :reloadOnRepeat,
              :icon,
              :count,
              :name,
              :hasRadio,
              :url,
              :artistName,
              :shortUrl,
              :length
      extra   :albumCount,
              :trackKeys


      def station
        @station ||= fetch_object(:radioKey, ArtistStation)
      end
      alias :radio :station
    end
  end
end
