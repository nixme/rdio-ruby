module Rdio
  module Types

    # An activity stream update.
    #
    # Not a standard Rdio Object Type.
    #
    class Activity < Base
      include NonStandard

      default :owner,
              :date,
              :update_type,
              :extra

      # Update types:
      # 0 - track added to collection
      # 1 - track added to playlist
      # 3 - friend added
      # 5 - user joined
      # 6 - comment added to track
      # 7 - comment added to album
      # 8 - comment added to artist
      # 9 - comment added to playlist
      # 10 - track added via match collection
      # 11 - user subscribed to Rdio
      # 12 - track synced to mobile

     protected

      def load_from_api_response(hash)
        hash = hash.dup
        @owner = User.new(hash.delete('owner'), client)
        @date = hash.delete('date')
        @update_type = hash.delete('update_type')
        @extra = hash
      end
    end
  end
end
