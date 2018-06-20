module GoCLI
  class CLI
    BANNER = <<~BANNER
      #####################################################################
           .oooooo.                        .oooooo.   ooooo        ooooo 
          d8P'  `Y8b                      d8P'  `Y8b  `888'        `888' 
         888            .ooooo.          888           888          888  
         888           d88' `88b         888           888          888  
         888     ooooo 888   888 8888888 888           888          888  
         `88.    .88'  888   888         `88b    ooo   888       o  888  
          `Y8bood8P'   `Y8bod8P'          `Y8bood8P'  o888ooooood8 o888o 
      #####################################################################
    
      >>> Welcome to Go-CLI v#{GoCLI::VERSION}!!!
    
      ======================================================================
    BANNER
    PROMPT = "> "

    attr_reader :app_session

    def start(options)
      system "cls"
      puts CLI::BANNER
      begin
        if options[:file]
          puts "Loading from #{options[:file]}"
          puts "Other settings will be overriden!" if options[:size] || options[:pos]
          @file = options[:file]
          @app_session = AppSession.load_session_file(@file)
          main_menu
        else
          user_session = login
          # TODO: initialize app_session
        end
      rescue => e
        puts "Error at initialization:"
        puts e.message
        puts e.backtrace
      end
      main_menu
    end

    def main_menu

    end

    def login
      username = "", password = ""
      Config::MAX_ATTEMPT.times do
        puts "Please enter your username: "
        print CLI::PROMPT
        entry = gets.strip
        if User.valid_username?(entry)
          username = entry
          break
        end
        puts "Invalid username pattern"
      end
      username = signup(username) unless User.exist?(username)

      # TODO: check if username is set

      Config::MAX_ATTEMPT.times do
        puts "Please enter your password (hidden): "
        print CLI::PROMPT
        entry = STDIN.noecho(&:gets).chomp
        if User.valid?(username, entry)
          password = entry
          break
        end
        puts "\nIncorrect password"
      end

      # TODO: check if password is set

      UserSession.new(username, password)
    end

    def signup(username)
      puts "Hello #{username}, we don't think you have signed up yet."
      loop do
        puts "Would you like to sign up? [y]es/[n]o"
        print CLI::PROMPT
        answer = gets.strip.downcase
        case answer
        when /y(es)?/
          tempuser = ""
          Config::MAX_ATTEMPT.times do
            puts "Please enter your username again [#{username}] (press ENTER to use previous value)"
            print CLI::PROMPT
            entry = gets.strip
            tempuser = entry.empty? ? username : entry
            unless User.valid_username?(tempuser)
              puts User::USERNAME_PATTERN_DESCRIPTION
              tempuser = ""
              next
            end
            break unless User.exist?(username)
            puts "Username taken, please use another username"
            tempuser = ""
          end
          close(ERR::TOO_MANY_ATTEMPTS) if tempuser.empty?
          username = tempuser
          password = ""
          # TODO: handle password input
          User.signup(username, password)
          break
        when /n(o)?/
          close(EXT::SUCCESS)
          break
        else
          puts "Invalid input"
        end
      end
      username
    end

    def user_session
      app_session.user_session
    end

    def close(exitcode = EXT::SUCCESS)
      puts "Thank you for using Go-CLI v#{VERSION}"
      puts "See you next time"
      exit exitcode
    end
  end
end