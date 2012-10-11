module Rdio
  module Types

    # Results from a get call. Enumerable and acts like a Hash keyed by Rdio
    # object key.
    #
    # Not a standard Rdio Object Type.
    #
    class GetResults < Base
      include NonStandard
      include Enumerable

      extend Forwardable
      def_delegators :@results, :[], :keys, :has_key?, :include?, :key?,
                                :member?, :length, :size


      # All fetched objects as an array, optionally in a specific key order.
      def results(order = keys)
        order.map { |key| @results[key] }
      end

      def each(&block)
        @results.values.each(&block)
      end


     protected

      def load_from_api_response(hash)
        @results = Hash[
          hash.map do |key, raw_object|
            [key, Types.autowrap(raw_object, client)]
          end
        ]
      end
    end
  end
end
