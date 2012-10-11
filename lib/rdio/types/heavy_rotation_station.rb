module Rdio
  module Types

    # A user's network's or global heavy rotation station.
    #
    class HeavyRotationStation < Base
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
