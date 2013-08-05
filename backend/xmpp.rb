module ChatBot

  require 'xmpp4r/client'
  require 'xmpp4r/muc'

  class XChatBot < ChatBot
    attr_reader :client
    def initialize(args)
      super
      if @nick == @username
        @nick = @username.split(/@/)[0]
      end
      @client = Jabber::Client.new(Jabber::JID.new username)
      connect!
    end
    def connect!
      if @server
        @client.connect @server
      else
        @client.connect
      end
      begin
        if @password.nil?
          puts 'Enter password'
          @password = STDIN.noecho { gets }.chomp
        end
        @client.auth @password
      rescue Jabber::ClientAuthenticationFailure => e
        puts e
        @password = nil
        retry
      end
    end
    def join!(chatroom, nick = @nick)
      # begin rescue?
      chatroom.join!(self, @nick)
      # end begin?
      @chatrooms.push chatroom
    end
    def disconnect!
    end
  end

  class XChatMessage < ChatMessage
  end

  class XChatRoom < ChatRoom
    def join!(chatbot, nick)
      @mucclient = Jabber::MUC::SimpleMUCClient.new chatbot.client
      @mucclient.join Jabber::JID.new("#{@chatroom}/#{nick}")

      # add event listener for history

      @mucclient.on_message do |time, sender, text|
        next if time # time is true if message is in the past
        message = XChatMessage.new({
          :text => text,
          :sender => sender,
          :time => time, # probably want to convert to Time object
          :priv => false,
        })
        chatbot.responses.each {|response| response.call(chatbot, self, message)}
      end
    end
    def say usermessage
      @mucclient.say usermessage
    end
    def msg(usermessage, nick)
      @mucclient.say(usermessage, nick)
    end
  end

end


