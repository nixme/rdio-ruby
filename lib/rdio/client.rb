require 'rdio/errors'
require 'rdio/types'
require 'rdio/utils'
require 'faraday'
require 'faraday_middleware'

module Rdio
  class Client
    attr_reader :consumer_key, :consumer_secret, :access_token, :secret


    def initialize(consumer_key, consumer_secret, access_token = nil, secret = nil)
      @consumer_key, @consumer_secret = consumer_key, consumer_secret
      @access_token, @secret = access_token, secret
    end

    def access_token=(access_token)
      @access_token = access_token
      @connection = nil
    end

    def secret=(secret)
      @secret = secret
      @connection = nil
    end

    def has_authorization_tokens?
      @access_token && @secret
    end

    # Define all the Rdio API methods as Rdio::Client methods
    #
    # Using a simple DSL to build flexible methods:
    #   <method_name> =>
    #     [oauth token required?, required args, optional args, result wrapper]
    #
    # All results are wrapped by an Rdio::Type class. If a 'result wrapper' is
    # specified, it's always used. If `nil`, the wrapper is autodetected from
    # the result's 'type' field.
    #
    # Each method is aliased so both snake_case and camelCase variants work.
    # Methods also take arguments in Rdio API documentation order, or as named
    # parameters through a hash. For example, the following are equivalent:
    #
    #  search('above and beyond', 'Artist')
    #  search(query: 'above and beyond', types: 'Artist')
    #
    # Each method also has a raw variant that returns the parsed JSON result
    # without wrapping in a type class. Just prefix `raw_` to the method name.
    #
    {
      # Core
      get:                            [false, [:keys], [:extras, :options], Types::GetResults],
      getObjectFromShortCode:         [false, [:short_code], [:extras]],
      getObjectFromUrl:               [false, [:url], [:extras]],

      # Catalog
      getAlbumsByUPC:                 [false, [:upc], [:extras]],
      getAlbumsForArtist:             [false, [:artist], [:featuring, :extras, :start, :count]],
      getTracksByISRC:                [false, [:isrc], [:extras]],
      getTracksForArtist:             [false, [:artist], [:appears_on, :extras, :start, :count]],
      search:                         [false, [:query, :types], [:never_or, :extras, :start, :count], Types::SearchResults],
      searchSuggestions:              [false, [:query], [:extras]],

      # Collection
      addToCollection:                [true,  [:keys], []],
      getAlbumsForArtistInCollection: [false, [:artist], [:user, :extras]],
      getAlbumsInCollection:          [false, [], [:user, :start, :count, :sort, :query, :extras]],
      getArtistsInCollection:         [false, [], [:user, :start, :count, :sort, :query, :extras]],
      getTracksForAlbumInCollection:  [false, [:album], [:user, :extras]],
      getTracksForArtistInCollection: [false, [:artist], [:user, :extras]],
      getTracksInCollection:          [false, [], [:user, :start, :count, :sort, :query, :extras]],
      removeFromCollection:           [true,  [:keys], []],
      setAvailableOffline:            [true,  [:keys, :offline], []],

      # Playlists
      addToPlaylist:                  [true,  [:playlist, :tracks], []],
      createPlaylist:                 [true,  [:name, :description, :tracks], [:extras]],
      deletePlaylist:                 [true,  [:playlist], []],
      getPlaylists:                   [true,  [], [:extras], Types::PlaylistsResult],
      removeFromPlaylist:             [true,  [:playlist, :index, :count, :tracks], []],
      setPlaylistCollaborating:       [true,  [:playlist, :collaborating], []],
      setPlaylistCollaborationMode:   [true,  [:playlist, :mode]],
      setPlaylistFields:              [true,  [:playlist, :name, :description], []],
      setPlaylistOrder:               [true,  [:playlist, :tracks], []],

      # Social Network
      addFriend:                      [true,  [:user], []],
      currentUser:                    [true,  [], [:extras]],
      findUser:                       [false, [], [:email, :vanityName, :extras]],
      removeFriend:                   [true,  [:user], []],
      userFollowers:                  [false, [:user], [:start, :count, :extras]],
      userFollowing:                  [false, [:user], [:start, :count, :extras]],

      # Activity and Statistics
      getActivityStream:              [false, [:user, :scope], [:last_id, :extras], Types::ActivityStream],
      getHeavyRotation:               [false, [], [:user, :type, :friends, :limit, :start, :count, :extras]],
      getNewReleases:                 [false, [], [:time, :start, :count, :extras]],
      getTopCharts:                   [false, [:type], [:start, :count, :extras]],

      # Playback
      getPlaybackToken:               [false, [], [:domain]]

    }.each do |name, (auth_required, required_args, optional_args, result_wrapper)|
      raw_version = "raw_#{name}"

      # Define the raw method that returns a hash converted from the result JSON.
      define_method raw_version do |*args|
        raise MissingUserCredentials if auth_required && !has_authorization_tokens?
        http_call(name, massage_args(args, required_args, optional_args))
      end

      # Define the normal method that returns a class wrapped result.
      define_method name do |*args|
        result = __send__(raw_version, *args)

        if result_wrapper
          result_wrapper.new(result, self)
        else
          Types.autowrap(result, self)
        end
      end

      # Idiomatic aliases
      [raw_version, name].each do |original|
        alias_method Utils.underscore_string(original), original   # snake_cased

        # For API calls starting with 'get' -- which isn't very idiomatic --
        # create truncated aliases. For example, 'getActivityStream' can be called
        # 4 ways: `getActivityStream`, `get_activity_stream`, `activityStream`,
        # and `activity_stream`.
        if /^(?<prefix>raw_)?get(?<short_name>.+)/ =~ original
          short_name = "#{prefix}#{short_name[0].downcase}#{short_name[1..-1]}"
          alias_method short_name, original
          alias_method Utils.underscore_string(short_name), original
        end
      end
    end

    def inspect
      Utils.custom_inspect(self, :@connection)
    end


   private

    ENDPOINT = 'http://api.rdio.com'
    VERSION  = 1

    def massage_args(args, required_args, optional_args)
      # Named parameter-style passing
      if args.size == 1 && args.first.is_a?(Hash)
        args.first

      # Regular argument passing but not enough arguments
      elsif args.size < required_args.size
        raise ArgumentError, "wrong number of arguments (#{args.size} for #{required_args.size})"

      # Regular argument passing
      else
        Hash[(required_args + optional_args).zip(args)]
      end
    end

    def http_call(method, params = {})
      params = params.select { |_, v| v }  # Strip nil params. Rdio no like :(

      response = connection.post do |request|
        request.url "/#{VERSION}/"
        request.body = Types.unwrap_params(params).merge(method: method.to_s)
      end

      body = response.body
      unless response.success? && body && body['status'] == 'ok'
        raise APIError, body && body['message']
      end

      body['result']
    end

    def connection
      @connection ||=
        begin
          oauth_params = {
            consumer_key:    @consumer_key,
            consumer_secret: @consumer_secret
          }

          if has_authorization_tokens?
            oauth_params.merge!(
              token:        @access_token,
              token_secret: @secret
            )
          end

          Faraday.new(url: ENDPOINT) do |builder|
            builder.use FaradayMiddleware::OAuth, oauth_params
            builder.use Faraday::Request::UrlEncoded
            builder.use FaradayMiddleware::ParseJson, content_type: /\bjson$/
            builder.adapter Faraday.default_adapter
          end
        end
    end
  end
end
