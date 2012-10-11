module Rdio
  module Types

    # A record label.
    #
    # Unsupported by the Rdio API. Documented, but no calls return a Label
    # object.
    #
    class Label < Base
      default :name,
              :key,
              :url,
              :shortUrl,
              :hasRadio,
              :radioKey
    end
  end
end
