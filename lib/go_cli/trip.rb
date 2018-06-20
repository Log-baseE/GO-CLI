module GoCLI
  class Trip
    attr_reader :username, :driver_id, :date,
                :start_xpos, :start_ypos, :end_xpos, :end_ypos, :route,
                :price

    def self.calculate_price(distance)
      Config::DEFAULT_PRICE_UNIT * distance
    end

    def self.get_by_username(username)
    end

    def initialize(username, driver_id, start_xpos, start_ypos, end_xpos, end_ypos)
      @username = username
      @driver_id = driver_id
      @date = DateTime.now
      @start_xpos = start_xpos
      @start_ypos = start_ypos
      @end_xpos = end_xpos
      @end_ypos = end_ypos
      @route = Route.generate(start_xpos, start_ypos, end_xpos, end_ypos)
      @price = Trip.calculate_price(@route.distance)
      # TODO: store to file
    end

    def details
    end
  end
end