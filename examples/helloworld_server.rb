# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('./examples/helloworld')

require 'griffin'
require 'helloworld_services_pb'

class GreeterServer < Helloworld::Greeter::Service
  def say_hello(hello_req, _unused_call)
    Helloworld::HelloReply.new(message: "Hello #{hello_req.name}")
  end
end

server = Griffin::Server.new
server.handle(GreeterServer.new)

server.start
