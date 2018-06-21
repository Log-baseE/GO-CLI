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
    BANNER
    PROMPT = "> "
    MAIN_MENU_BANNER = BANNER + <<~MAIN
      |#{" "*((48-GoCLI::VERSION.length)/2).floor + "Welcome to Go-CLI v#{GoCLI::VERSION}" + " "*((48-GoCLI::VERSION.length)/2.0).ceil}|
      |                            MAIN MENU                              |
      =====================================================================
    MAIN
    LOGIN_BANNER = BANNER + <<~LOGIN
      |                              LOGIN                                |
      =====================================================================
    LOGIN
    SIGNUP_BANNER = BANNER + <<~SIGNUP
      |                             SIGN UP                               |
      =====================================================================
    SIGNUP
    ORDER_RIDE_BANNER = BANNER + <<~ORDER
      |                           ORDER  RIDE                             |
      =====================================================================
    ORDER
    VIEW_MAP_BANNER = BANNER + <<~MAP
      |                            VIEW  MAP                              |
      =====================================================================
    MAP
    VIEW_TRIPS_BANNER = BANNER + <<~HISTORY
      |                           VIEW  TRIPS                             |
      =====================================================================
    HISTORY

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
          world_size = options[:size] ? options[:size] : Config::DEFAULT_WORLD_SIZE
          user_xpos = options[:pos] && options[:pos][0] ? options[:pos][0] : rand(1..world_size)
          user_ypos = options[:pos] && options[:pos][1] ? options[:pos][1] : rand(1..world_size)
          user_session.xpos, user_session.ypos = user_xpos, user_ypos
          positions = [[user_xpos, user_ypos]]
          driver_id_list = Driver.random_sample(Config::DEFAULT_DRIVER_AMOUNT)
          positions << [rand(1..world_size), rand(1..world_size)] while positions.uniq.size < Config::DEFAULT_DRIVER_AMOUNT + 1
          positions.uniq!
          positions.shift
          driver_sessions = driver_id_list.map.with_index { |driver_id, index| DriverSession.new(driver_id, *positions[index]) }
          @app_session = AppSession.new(user_session, world_size, driver_sessions)
        end
      rescue => e
        puts "Error at initialization:"
        puts e.message
        puts e.backtrace
      end
      main_menu
    end

    def main_menu
      error = false
      loop do
        system "cls"
        puts CLI::MAIN_MENU_BANNER
        puts <<~MAIN
          Hello #{user_session.username}, you are currently in (#{user_session.xpos}, #{user_session.ypos})
          Debt: #{user_session.user.debt}

          Please choose an option:

          1) View Map
          2) Order Go-RIDE
          3) View trip history

          0) Exit

        MAIN
        puts "Input a valid value!" if error
        print CLI::PROMPT
        choice = gets.strip
        choice = -1 unless /\d+/.match? choice
        choice = choice.to_i
        case choice
        when 0
          close
          break
        when 1
          error = false
          display_map
        when 2
          error = false
          order_ride
        when 3
          error = false
          view_trip_history
        else
          error = true
        end
        print CLI::PROMPT
      end
    end

    def login
      system "cls"
      puts CLI::LOGIN_BANNER
      username = ""
      password = ""
      Config::MAX_ATTEMPT.times do
        puts "Please enter your username: "
        print CLI::PROMPT
        entry = gets.strip
        if User.valid_username?(entry)
          username = entry
          break
        end
        puts User::USERNAME_PATTERN_DESCRIPTION
      end
      close(ERR::TOO_MANY_ATTEMPTS) if username.empty?
      
      exist = User.exist?(username)
      username = signup(username) unless User.exist?(username)
      puts CLI::LOGIN_BANNER unless exist 

      Config::MAX_ATTEMPT.times do
        puts "Please enter your password to log in (hidden): "
        print CLI::PROMPT
        entry = STDIN.noecho(&:gets).chomp
        if User.valid?(username, entry)
          password = entry
          break
        end
        puts "\nIncorrect password"
      end

      close(ERR::TOO_MANY_ATTEMPTS) if password.empty?

      UserSession.new(username, password)
    end

    def signup(username)
      system "cls"
      puts CLI::SIGNUP_BANNER
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

          temp_pass = ""
          Config::MAX_ATTEMPT.times do
            puts "Please enter your password (hidden): "
            print CLI::PROMPT
            temp_pass = STDIN.noecho(&:gets).chomp
            puts "\nPlease confirm your password (hidden): "
            print CLI::PROMPT
            confirm_entry = STDIN.noecho(&:gets).chomp
            puts ""
            break if temp_pass == confirm_entry
            puts "Password mismatch"
            temp_pass = ""
          end
          close(ERR::TOO_MANY_ATTEMPTS) if temp_pass.empty?
          password = temp_pass
          
          User.signup(username, password)
          break
        when /n(o)?/
          close(EXT::SUCCESS)
          break
        else
          puts "Invalid input"
        end
      end
      system "cls"
      username
    end

    def display_map
      system "cls"
      puts CLI::VIEW_MAP_BANNER
      puts @app_session.draw_world
      puts ""
      system "pause"
    end

    def order_ride
      error = false
      dest = []
      system "cls"
      puts CLI::ORDER_RIDE_BANNER
      loop do
        puts "Please enter your destination [x y]"
        puts "Invalid input!" if error
        print CLI::PROMPT
        entry = gets.strip.split(/[, ]+/).map(&:to_i)
        if entry.size == 2 && @app_session.world.valid_coordinate?(*entry)
          error = false
          dest = entry
          break
        else
          error = true
        end
      end
      puts "Finding nearest driver..."
      min_driver, min_distance = @app_session.get_closest_driver
      puts "Driver found!"
      puts ""
      temp_trip = Trip.create(user_session.user_id, min_driver.driver_id, user_session.xpos, user_session.ypos, *dest)
      puts min_driver.details
      puts "Distance from you : #{min_distance} units"
      puts @app_session.draw_route(min_driver.xpos, min_driver.ypos, temp_trip.route)
      puts ""
      loop do
        puts "Confirm ride? [y]es/[n]o"
        puts "Invalid input!" if error
        print CLI::PROMPT
        entry = gets.strip
        case entry
        when /y(es)?/
          error = false
          puts "Ride confirmed"
          user_session.do_trip(temp_trip)
          loop do
            puts "Please rate your ride (1-5)"
            puts "Please input a valid rating!" if error
            print CLI::PROMPT
            entry = gets.strip.to_i
            if Trip.valid_rating?(entry)
              error = false
              temp_trip.rate(entry)
              break
            else
              error = true
            end
          end
          break
        when /n(o)?/
          error = false
          puts "Ride cancelled"
          break
        end
      end
      system "pause"
    end

    def view_trip_history
      system "cls"
      puts CLI::VIEW_TRIPS_BANNER
      puts 
    end

    def user_session
      app_session.user_session
    end

    def close(exitcode = EXT::SUCCESS)
      puts "ERRCODE: #{exitcode}" unless exitcode == EXT::SUCCESS
      puts "Thank you for using Go-CLI v#{VERSION}"
      puts "See you next time"
      exit exitcode
    end
  end
end