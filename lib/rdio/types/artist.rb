module Rdio
  module Types

    # An artist, either an individual performer or a group.
    #
    class Artist < Base
      default :name,
              :key,
              :url,
              :length,
              :icon,
              :baseIcon,
              :hasRadio,
              :shortUrl,
              :radioKey,
              :topSongsKey
      extra   :albumCount


      def top_songs_station
        @top_songs_station ||= fetch_object(:topSongsKey, ArtistTopSongsStation)
      end

      def station
        @station ||= fetch_object(:radioKey, ArtistStation)
      end
      alias :radio :station
    end
  end
end
