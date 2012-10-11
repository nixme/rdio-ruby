module Rdio
  module Types

    # A user's collection's station.
    #
    class UserCollectionStation < Base
      default :key,
              :length,
              :tracks,
              :reloadOnRepeat,
              :count,
              :user,
              :baseIcon,
              :icon,
              :name,
              :url
      extra   :trackKeys
    end
  end
end
