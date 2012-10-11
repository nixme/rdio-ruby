module Rdio
  module Types

    # A playlist.
    #
    class Playlist < Base
      default :name,
              :length,
              :url,
              :icon,
              :baseIcon,
              :owner,
              :ownerUrl,
              :ownerKey,
              :ownerIcon,
              :lastUpdated,
              :shortUrl,
              :embedUrl,
              :key
      extra   :iframeUrl,
              :isViewable,
              :bigIcon,
              :description,
              :tracks,
              :isPublished,
              :trackKeys,
              :reasonNotViewable


      def owner_object
        @owner_object ||= fetch_object(:ownerKey, User)
      end

      # Override the default reader to pull tracks from trackKeys if not fetched
      # already.
      def tracks
        @tracks ||= fetch_collection(:trackKeys, Track)
      end
    end
  end
end
