module Rdio
  module Types

    # Results from a search query. Enumerable.
    #
    # Not a standard Rdio Object Type.
    #
    class SearchResults < Base
      include NonStandard
      include Enumerable

      default :person_count,
              :track_count,
              :album_count,
              :playlist_count,
              :artist_count,
              :number_results

      alias :number_of_results :number_results
      alias :count             :number_results

      extend Forwardable
      def_delegators :@results, :each, :[], :slice, :at, :last, :length,
                                :sample, :shuffle


     protected

      def load_from_api_response(hash)
        super
        @results = Types.autowrap(hash['results'], client)
      end
    end
  end
end
