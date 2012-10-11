module Rdio
  class APIError < StandardError; end
  class UnknownType < StandardError; end
  class MissingUserCredentials < StandardError; end

  module Types
    class MissingAttribute < StandardError
      def initialize(name)
        @name = name
      end

      def message
        "Cannot fetch related object(s) without '#{@name}'. Try reloading the object first."
      end
    end
  end
end
