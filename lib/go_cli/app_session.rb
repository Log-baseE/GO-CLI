require 'yaml'
require_relative 'world'
require_relative 'utils'
require_relative 'user_session'
require_relative 'driver'
require_relative 'errors'

module GoCLI
  class AppSession
    attr_reader :world, :user_session, :driver_sessions

    def self.load_session_file(filename, user_session)
      app_session = Utils.load_file(filename)
      begin
        loaded_user_session = app_session.user_session
        user_session.xpos = loaded_user_session.xpos
        user_session.ypos = loaded_user_session.ypos
        driver_sessions = app_session.driver_sessions.map { |ds| DriverSession.new(ds.driver_id, ds.xpos, ds.ypos) }
        AppSession.new(user_session, app_session.world.size, driver_sessions)
      rescue 
        raise BadFileError, filename
      end
    end

    def initialize(user_session, world_size, driver_sessions = nil)
      @user_session = user_session
      driver_amount = driver_sessions ? driver_sessions.size : Config::DEFAULT_DRIVER_AMOUNT
      min_size = Math.sqrt(driver_amount + 1).ceil
      raise ArgumentError, "World size too small, must be at least #{min_size}" unless world_size >= min_size
      @driver_sessions = 
        if driver_sessions
          driver_sessions
        else
          positions = [[user_session.xpos, user_session.ypos]]
          driver_id_list = Driver.random_sample(Config::DEFAULT_DRIVER_AMOUNT)
          positions << [rand(1..world_size), rand(1..world_size)] while positions.uniq.size < Config::DEFAULT_DRIVER_AMOUNT + 1
          positions.uniq!
          positions.shift
          driver_sessions = driver_id_list.map.with_index { |driver_id, index| DriverSession.new(driver_id, *positions[index]) }
        end
      @world = World.new(world_size)
      raise ArgumentError, "Invalid coordinates" unless @world.valid_coordinate?(user_session.xpos, user_session.ypos) && driver_sessions.all? { |ds| @world.valid_coordinate?(ds.xpos, ds.ypos) }
    end

    def empty_map_matrix
      map = [] << "╔" + "═" * @world.size + "╗"
      @world.size.times { map << ("║" + Config::MAP_EMPTY_CHAR * @world.size + "║") }
      map << "╚" + "═" * @world.size + "╝"
    end

    def draw_world
      map = empty_map_matrix
      map[user_session.ypos][user_session.xpos] = Config::MAP_USER_CHAR
      driver_sessions.each { |ds| map[ds.ypos][ds.xpos] = Config::MAP_DRIVER_CHAR }
      map = map.join("\n")
      legend = <<~LEGEND
      Legend:
      #{Config::MAP_USER_CHAR}: you!
      #{Config::MAP_DRIVER_CHAR}: driver
      LEGEND
      [map, legend].join("\n")
    end

    def get_closest_driver
      distance = driver_sessions.map { |ds| Route.generate(ds.xpos, ds.ypos, user_session.xpos, user_session.ypos).distance }
      min_driver_session = driver_sessions.at(distance.each_with_index.min[1])
      [min_driver_session, distance.min]
    end

    def load_trips
      Trip.get_by_user_id(@user_session.user_id).sort_by { |trip| trip.date }
    end

    def get_trip_descriptions
      descriptions = load_trips.each_with_index.map { |trip, index| "#{index+1}) #{trip.description}" }
    end

    def get_trip_details(index)
      trip = load_trips[index]
      details = <<~DETAIL
        TRIP DETAILS (#{trip.date.strftime("%d %b %Y (%H:%M)")}

        From\t\t: #{trip.start_xpos}, #{trip.start_ypos}
        Destination\t: #{trip.end_xpos}, #{trip.end_ypos}
        Distance\t: #{trip.route.distance}
        Price\t\t: #{trip.price}
        Driver\t\t: #{Driver.load_data(trip.driver_id).name}
        Rating\t\t: #{trip.rating}
        Route taken\t:
      DETAIL
      map = empty_map_matrix
      trip.route.each_cons(2) do |node1, node2|
        if node2[1] == node1[1]
          ([node1[0], node2[0]].min..[node1[0], node2[0]].max).each do |x|
            map[node1[1]][x] = Config::MAP_ROUTE_CHAR
          end
        elsif node2[0] == node1[0]
          ([node1[1], node2[1]].min..[node1[1], node2[1]].max).each do |y|
            map[y][node1[0]] = Config::MAP_ROUTE_CHAR
          end
        end
      end
      map[trip.start_ypos][trip.start_xpos] = Config::MAP_USER_CHAR
      map[trip.end_ypos][trip.end_xpos] = Config::MAP_DESTINATION_CHAR
      # map.join("\n")
      legend = <<~LEGEND
        Legend:
        #{Config::MAP_USER_CHAR}: you!
        #{Config::MAP_DESTINATION_CHAR}: destination
        #{Config::MAP_ROUTE_CHAR}: route
      LEGEND
      [details, map, legend].join("\n")
    end

    def draw_route(driver_xpos, driver_ypos, route)
      banner = "-"*32 + " MAP " + "-"*32
      map = empty_map_matrix
      route.each_cons(2) do |node1, node2|
        if node2[1] == node1[1]
          ([node1[0], node2[0]].min..[node1[0], node2[0]].max).each do |x|
            map[node1[1]][x] = Config::MAP_ROUTE_CHAR
          end
        elsif node2[0] == node1[0]
          ([node1[1], node2[1]].min..[node1[1], node2[1]].max).each do |y|
            map[y][node1[0]] = Config::MAP_ROUTE_CHAR
          end
        end
      end
      map[driver_ypos][driver_xpos] = Config::MAP_DRIVER_CHAR
      map[@user_session.ypos][@user_session.xpos] = Config::MAP_USER_CHAR
      map[route.end_pos[1]][route.end_pos[0]] = Config::MAP_DESTINATION_CHAR
      legend = <<~LEGEND
        Legend:
        #{Config::MAP_USER_CHAR}: you!
        #{Config::MAP_DESTINATION_CHAR}: destination
        #{Config::MAP_DRIVER_CHAR}: driver
        #{Config::MAP_ROUTE_CHAR}: route
      LEGEND
      [banner, map, legend].join("\n")
    end
    def do_trip(trip)
      trip.store
      user_session.do_trip(trip)
    end
  
    def store(filename)
      Utils.write_file(self, filename)
    end
  end

end