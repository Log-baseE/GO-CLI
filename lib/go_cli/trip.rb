module GoCLI
  class Trip
    attr_reader :user_id, :driver_id, :date,
                :start_xpos, :start_ypos, :end_xpos, :end_ypos, :route,
                :rating, :price

    def self.calculate_price(distance)
      Config::DEFAULT_PRICE_UNIT * distance
    end

    def self.get_by_user_id(user_id)
      trip_user_map = Utils.load_yml_file(Config::TRIP_USER_MAPFILE)
      trip_files = trip_user_map[user_id]
    end

    def self.get_by_driver(driver_id)
      trip_driver_map = Utils.load_yml_file(Config::TRIP_DRIVER_MAPFILE)
      trip_files = trip_driver_map[driver_id]
    end

    def self.load_trip_file(filename)
      trip = Utils.load_file(filename)
      begin
        Trip.new(
          trip.user_id, trip.driver_id, trip.date, 
          trip.start_xpos, trip.start_ypos, trip.end_xpos, 
          trip.end_ypos, trip.route, trip.price, trip.filename
          )
      rescue
        raise BadFileError, filename
      end
    end

    def store
      filename = @filename

      Utils.write_file(self, filename)
      trip_user_map = Utils.load_yml_file(Config::TRIP_USER_MAPFILE)
      trip_user_map[user_id] = [] unless trip_user_map[user_id]
      trip_user_map[user_id] << filename if trip_user_map[user_id].include?(filename)
      Utils.write_yml_file(trip_user_map, Config::TRIP_USER_MAPFILE)
      trip_driver_map = Utils.load_yml_file(Config::TRIP_DRIVER_MAPFILE)
      trip_driver_map[driver_id] = [] unless trip_driver_map[driver_id]
      trip_driver_map[driver_id] << filename if trip_user_map[user_id].include?(filename)
      Utils.write_yml_file(trip_driver_map, Config::TRIP_DRIVER_MAPFILE)
      self
    end

    def self.create(user_id, driver_id, start_xpos, start_ypos, end_xpos, end_ypos)
      route = Route.generate(start_xpos, start_ypos, end_xpos, end_ypos)
      price = Trip.calculate_price(route.distance)
      Trip.new(user_id, driver_id, DateTime.now, start_xpos, start_ypos, end_xpos, end_ypos, route, price, 5)
    end

    def self.valid_rating?(rating)
      (Config::MIN_RATING..Config::MAX_RATING).include? rating
    end

    def generate_id
      Digest::SHA1.hexdigest("#{@username}#{@driver_id}#{@date}#{start_xpos}#{start_ypos}#{end_xpos}#{end_ypos}")
    end

    def generate_filename
      trip_id = generate_id
      Config::TRIP_DATA_DIR + "#{trip_id}.yml"
    end

    def initialize(username, driver_id, date, start_xpos, start_ypos, end_xpos, end_ypos, route, price, rating, filename = nil)
      @username = username
      @driver_id = driver_id
      @date = date
      @start_xpos = start_xpos
      @start_ypos = start_ypos
      @end_xpos, @end_ypos = end_xpos, end_ypos
      @route = route
      @price = price
      @rating = rating
      @filename = filename ? filename : generate_filename
    end

    def rate(rating)
      raise ArgumentError, "Bad rating! (must be #{Config::MIN_RATING}-#{Config::MAX_RATING})" unless Trip.valid_rating?(rating)
      @rating = rating
      store
    end

    def description

    end
  end
end