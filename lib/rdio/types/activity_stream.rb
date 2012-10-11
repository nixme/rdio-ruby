module Rdio
  module Types

    # Result from a getActivityStream call.
    #
    # Not a standard Rdio Object Type.
    #
    class ActivityStream < Base
      include NonStandard

      default :last_id,
              :user
              :updates


     protected

      def load_from_api_response(hash)
        @last_id = hash['last_id']
        @user = User.new(hash['user'], client)
        @updates = hash['updates'].map { |update| Activity.new(update, client) }
      end
    end
  end
end
