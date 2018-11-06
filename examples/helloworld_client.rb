# frozen_string_literal: false

$LOAD_PATH.unshift File.expand_path('./examples/helloworld')

require 'griffin'
require 'socket'
require 'pry'
require 'helloworld_services_pb'

Griffin::Client.register do |c|
  c.service Helloworld::Greeter

  c.bind '0.0.0.0'

  c.port 50051
end

v = Helloworld::Greeter::Client.new

p v
# v.say_hello(Helloworld::HelloRequest.new(name: 'ganmacs')).message


# stub = Helloworld::Greeter::Stub.new('localhost', 50051)
# message = stub.say_hello(Helloworld::HelloRequest.new(name: 'ganmacs')).message
# p message
