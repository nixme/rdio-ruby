module Rdio
  module Types

    # A user's heavy rotation station.
    #
    class HeavyRotationUserStation < Base
      default :key,
              :length,
              :tracks,
              :reloadOnRepeat,
              :count,
              :user,
              :baseIcon,
              :icon,
              :name
      extra   :trackKeys
    end
  end
end
