module Rdio
  module Types

    # Result from a getPlaylists call.
    #
    # Not a standard Rdio Object Type.
    #
    class PlaylistsResult < Base
      include NonStandard

      default :owned,
              :collab,
              :subscribed


     protected

      def load_from_api_response(hash)
        @owned = Playlist.new(hash['owned'], client)
        @collab = Playlist.new(hash['collab'], client)
        @subscribed = Playlist.new(hash['subscribed'], client)
      end
    end
  end
end
