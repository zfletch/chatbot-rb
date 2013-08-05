module ChatBot

  def self.funcs_from_dir dirname
    Dir.entries(dirname).select {|n| n !~ /^\./}.map do |entry|
      eval File.open("#{dirname}/#{entry}") {|file| file.read}
    end
  end

  # chat bot
  class ChatBot
    attr_reader :username, :nick, :server
    attr_accessor :responses, :utilities
    def initialize(args)
      @username = args[:username]
      @password = args[:password]
      @nick = args[:nick] || @username
      @server = args[:server]
      @responses = args[:responses] || []
      @utilities = args[:utilities] || []
      @chatrooms = []
    end
    def connect!
      puts 'Connected'
    end
    def join! chatroom
    end
    def disconnect!
      puts 'Disconnected'
    end
    def crontest(time, time_info)
      time_info.each do |key, val|
        case key
        when :wday
          return false unless val.member? time.wday
        when :hour
          return false unless val.member? time.hour
        when :min
          return false unless val.member? time.min
        end
      end
      return true
    end
    def start_eventmachine!
      require 'eventmachine'
      @time = Time.new
      EventMachine.run do
        EventMachine::PeriodicTimer.new(30) do
          time = Time.new
          @utilities.each do |util|
            time_info = util[:time]
            util_func = util[:func]
            should_fire = crontest(time, time_info) && !crontest(@time, time_info)
            util_func.call(client) if should_fire
          end
          @time = time
        end
      end
    end
  end

  # message from the chat server to the users[s]
  class ChatMessage
    attr_reader :text, :sender, :time, :info
    def initialize(args)
      @text = args[:text]
      @sender = args[:sender]
      @time = args[:time]
      @info = args[:info] || {}
      @priv = args[:priv]
    end
    def private?
      @priv
    end
  end

  # chat room
  class ChatRoom
    attr_reader :users, :nick
    def initialize(chatroom, password = nil)
      @chatroom = chatroom
      @password = password
      @history = []
    end
    def join!(chatbot, nick)
      puts "Joined #{@chatroom} with nick #{nick}"
    end
    def history(lines = 20)
      size = @history.size
      return @history[(size - 20)..size]
    end
    def say usermessage
      puts usermessage.text
    end
    def msg(usermessage, nick)
      puts "#{usermessage.text} sent to #{nick}"
    end
  end

end