require 'rdio/types'
require 'rdio/utils'
require 'faraday'
require 'faraday_middleware'
require 'rash'

class Rdio::Client
  include Rdio::Types

  ENDPOINT = 'http://api.rdio.com'
  VERSION  = 1

  attr_reader :access_token, :secret

  def initialize(consumer_key, consumer_secret, access_token = nil, secret = nil)
    @consumer_key = consumer_key
    @consumer_secret = consumer_secret
    @access_token = access_token
    @secret = secret

    @connection = build_connection
  end

  def access_token=(access_token)
    @access_token = access_token
    @connection = build_connection
  end

  def secret=(secret)
    @secret = secret
    @connection = build_connection
  end

  def has_authorization_tokens?
    @access_token && @secret
  end

  # Define all the Rdio API methods as Rdio::Client methods
  #
  # Using a simple DSL to build flexible methods:
  #   <method_name> => [oauth token required?, required args, optional args]
  #
  # Each method is aliased so both snake_case and camelCase variants work.
  # Methods also take
  {
    # Core
    get:                            [false, [:keys], [:extras, :options]],
    getObjectFromShortCode:         [false, [:short_code], [:extras]],
    getObjectFromUrl:               [false, [:url], [:extras]],

    # Catalog
    getAlbumsByUPC:                 [false, [:upc], [:extras]],
    getAlbumsForArtist:             [false, [:artist], [:featuring, :extras, :start, :count]],
    getTracksByISRC:                [false, [:isrc], [:extras]],
    getTracksForArtist:             [false, [:artist], [:appears_on, :extras, :start, :count]],
    search:                         [false, [:query, :types], [:never_or, :extras, :start, :count]],
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
    getPlaylists:                   [true,  [], [:extras]],
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
    getActivityStream:              [false, [:user, :scope], [:last_id, :extras]],
    getHeavyRotation:               [false, [], [:user, :type, :friends, :limit, :start, :count, :extras]],
    getNewReleases:                 [false, [], [:time, :start, :count, :extras]],
    getTopCharts:                   [false, [:type], [:start, :count, :extras]],

    # Playback
    getPlaybackToken:               [false, [], [:domain]]

  }.each do |name, (auth_required, required_args, optional_args)|

    # Define a method for each Rdio API method
    define_method name do |*args|
      raise 'Missing OAuth token and secret' if auth_required && !has_authorization_tokens?
      call name, massage_args(args, required_args, optional_args)
    end

    # Alias the Rdio method name to a snake_cased idiomatic Ruby name
    alias_method Rdio::Utils.underscore_string(name).to_sym, name

    # For API calls starting with 'get' -- which isn't very idiomatic -- create
    # truncated aliases. For example, 'getActivityStream' can be called 4 ways:
    # `getActivityStream`, `get_activity_stream`, `activityStream`, and
    # `activity_stream`.
    if /^get(?<short_name>.+)/ =~ name
      short_name = short_name[0].downcase + short_name[1..-1]
      alias_method short_name.to_sym, name
      alias_method Rdio::Utils.underscore_string(short_name).to_sym, name
    end
  end


 private

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

  def call(method, params = {})
    params = params.select { |_, v| v }   # Strip nil params. Rdio no like :(

    response = @connection.post do |request|  # Make HTTP request
      request.url "/#{VERSION}/"
      request.body = params.merge(method: method.to_s)
    end

    body = response.body                      # Check for API errors
    unless body.status == 'ok'
      raise "API Error: #{body.message}"
    end

    wrap_result self, body.result             # Wrap results in type classes
  end

  def build_connection
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
      #builder.use Faraday::Response::Logger
      builder.use FaradayMiddleware::Rashify
      builder.use FaradayMiddleware::ParseJson, content_type: /\bjson$/
      builder.adapter Faraday.default_adapter
    end
  end
end
