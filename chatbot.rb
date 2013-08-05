#!/usr/bin/env ruby
# encode: UTF-8
# version 0.4

require 'io/console'
require 'eventmachine'
require 'optparse'
require 'ostruct'

require_relative './backend/backend'

options = OpenStruct.new
options.nick = 'hatbot'
options.debug = false
options.response_dir = './responses'
options.util_dir = './utilities'

chatbot = nil

required = [
  :username,
  :chatroom,
  :type,
]

OptionParser.new do |opts|
  opts.banner = 'Hatbot the chatbot'
  opts.on('-h', '--help', 'Show this message') { puts opts; exit }
  opts.on('-u', '--username USERNAME', "Username, eg 'foo@bar.com/baz'") {|u| options.username = u}
  opts.on('-s', '--server SERVER', "Server to connect to (optional), eg 'talk.foo.com'") {|s| options.server = s}
  opts.on('-c', '--chatroom CHATROOM', "Chatroom, eg 'foo@conference.bar.com'") {|c| options.chatroom = c}
  opts.on('-n', '--nick NICK', 'Nick name for chatroom, default hatbot') {|n| options.nick = n}
  opts.on('--responsedir RESPONSEDIR', "Directory of the response functions, default ./responses/") {|r| options.response_dir = r}
  opts.on('--utildir UTILDIR', "Directory of the utility functions, default ./utilities/") {|u| options.util_dir = u}
  opts.on('-t', '--type TYPE', "Chat protocol to use, eg XMPP") {|t| options.type = t}
  opts.on('--no-utils', "Don't use any utilities, only responses") { options.no_utils = true }
  opts.on('--debug', 'Print debug information') { options.debug = true }
  opts.parse!
  missing = required.select {|n| !options[n]}
  if missing.size > 0
    puts "Missing arguments: #{missing.join(', ')}"
    puts opts
    exit
  end
end

responses = ChatBot::funcs_from_dir options.response_dir
utilities = ChatBot::funcs_from_dir options.util_dir

case options.type
when (/^(?:jabber|xmpp)$/i)
  require_relative './backend/xmpp'
  if options.debug
    Jabber::debug = true
  end
  chatbot = ChatBot::XChatBot.new({
    :username => options.username,
    :password => options.password,
    :nick => options.nick,
    :server => options.server,
    :responses => responses,
    :utilities => utilities,
  })
  chatroom = ChatBot::XChatRoom.new(options.chatroom)
  chatbot.join! chatroom
else
  puts "Unrecognized type: #{options.type}"
  puts "Currently supported: xmpp"
  exit
end

at_exit do
  if chatbot
    chatbot.disconnect!
  end
end

trap 'SIGINT' do
  exit
end

loop { }

