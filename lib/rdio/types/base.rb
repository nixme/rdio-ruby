require 'rdio/utils'

module Rdio
  module Types

    # Abstract base class for Rdio Object Types
    # (http://developer.rdio.com/docs/read/rest/types)
    #
    # Subclasses must declare `default` and `extra` fields.
    #
    class Base

      class << self
        attr_reader :all_fields, :default_fields, :extra_fields

        def inherited(subclass)
          subclass.class_eval do
            @all_fields, @default_fields, @extra_fields = [], [], []
          end
        end

        # Declare the 'Default Fields' from Rdio's Object Types documentation
        def default(*fields)
          @all_fields.push *fields
          @default_fields.push *fields
          define_readers fields
        end

        # Declare the 'Available Fields' from Rdio's Object Types documentation
        def extra(*fields)
          @all_fields.push *fields
          @extra_fields.push *fields
          define_readers fields
        end


       private

        def define_readers(fields)
          attr_reader *fields

          # Idiomatic readers:
          #   'artistUrl' => 'artist_url'
          #   'isClean'   => 'is_clean' and 'clean?'
          #   'canSample' => 'can_sample' and 'sampleable?
          fields.each do |field|
            underscored = Rdio::Utils.underscore_string(field)
            unless underscored == field.to_s
              alias_method underscored.to_sym, field
            end

            if underscored =~ /(?:is|has)_(.*)/
              alias_method "#{$1}?".to_sym, field
            elsif underscored =~ /can_(.*)/
              alias_method "#{$1}able?".to_sym, field
            end
          end
        end
      end


      attr_reader :client

      def initialize(source_hash, client)
        @client = client
        load_from_api_response source_hash
      end

      # Refresh this object's data. Uses the 'get' API call.
      #
      def reload(with_extra_fields = true)
        params = { keys: key }
        params.merge!(extras: self.class.extra_fields) if with_extra_fields

        load_from_api_response client.raw_get(params)[key]
        self
      end

      def ==(other)
        key && other.key && key == other.key
      end

      def inspect
        Utils.custom_inspect(self, :@client)
      end


     protected

      def load_from_api_response(hash)
        self.class.all_fields.each do |field|
          value = hash[field.to_s]
          if value.is_a?(Array) || (value.is_a?(Hash) && value['type'])
            value = Types.autowrap(value, client)
          end
          instance_variable_set :"@#{field}", value
        end
      end

      def fetch_object(attribute, wrapper)
        raise MissingAttribute.new(attribute) unless (key = __send__(attribute))
        client.get(key, wrapper.extra_fields)[key]
      end

      def fetch_collection(attribute, wrapper)
        raise MissingAttribute.new(attribute) unless (keys = __send__(attribute))
        client.get(keys, wrapper.extra_fields).results(keys)
      end
    end

    # Mixin for types that are custom to this library.
    module NonStandard
      def reload
        raise 'Cannot reload a non-standard result object'
      end
    end
  end
end
