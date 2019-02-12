# Griffin

[![Gem Version](https://badge.fury.io/rb/griffin.svg)](https://badge.fury.io/rb/griffin)

Griffin is [gRPC](https://grpc.io/) server which supports multi process by using [serverengine](https://github.com/treasure-data/serverengine).
Griffin also supports building gRPC client.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'griffin'
```

And then execute:

```
$ bundle
```

Or install it yourself as:

```
gem install griffin
```

## Usage

#### Server

```ruby
class GreeterServer < Helloworld::Greeter::Service
  def say_hello(hello_req, _unused_call)
    Helloworld::HelloReply.new(message: "Hello #{hello_req.name}")
  end
end

Griffin::Server.configure do |c|
  c.bind '127.0.0.1'

  c.port 50051

  c.services GreeterServer.new

  c.worker 2 # A number of worker process
end

Griffin::Server.run

```

## Interceptors

* [cookpad/griffin-interceptors](https://github.com/cookpad/griffin-interceptors) colloection of interceptors

## Development

```
bundle install
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ganmacs/griffin.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

