rdio-ruby [WIP]
===============

A Ruby wrapper for the Rdio Web Service API.

## Usage

For unauthenticated calls:

```ruby
client = Rdio::Client.new(consumer_key, consumer_secret)
```

This library doesn't handle the OAuth authentication dance. omniauth-rdio is
recommended for web applications.

Have an OAuth access token and secret for an Rdio user?

```ruby
client.access_token = access_token
client.secret = secret
```

Now you can make authenticated calls.
