module Rdio
  module Types

    # An Rdio user.
    #
    class User < Base
      default :key,
              :firstName,
              :lastName,
              :icon,
              :baseIcon,
              :libraryVersion,
              :url,
              :gender
      extra   :followingUrl,
              :isTrial,
              :artistCount,
              :lastSongPlayed,
              :heavyRotationKey,
              :networkHeavyRotationKey,
              :albumCount,
              :trackCount,
              :lastSongPlayTime,
              :username,
              :reviewCount,
              :collectionUrl,
              :playlistsUrl,
              :collectionKey,
              :followersUrl,
              :displayName,
              :isUnlimited,
              :isSubscriber


      def heavy_rotation_station
        @heavy_rotation_station ||= fetch_object(:heavyRotationKey, HeavyRotationUserStation)
      end
      alias :heavy_rotation_radio :heavy_rotation_station

      def network_heavy_rotation_station
        @network_heavy_rotation_station ||= fetch_object(:networkHeavyRotationKey, HeavyRotationUserStation)
      end
      alias :network_heavy_rotation_radio :network_heavy_rotation_station

      def collection_station
        @collection_station ||= fetch_object(:collectionKey, UserCollectionStation)
      end
      alias :collection_radio :collection_station
    end
  end
end
