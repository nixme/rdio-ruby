module Rdio
  module Types

    # An artist recommendations station.
    #
    class ArtistStation < Base
      default :key,
              :topSongsKey,
              :baseIcon,
              :tracks,
              :artistUrl,
              :radioKey,   # Equivalent to :key
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


      def top_songs_station
        @top_songs_station ||= fetch_object(:topSongsKey, ArtistTopSongsStation)
      end
      alias :top_songs_radio :top_songs_station
    end
  end
end
