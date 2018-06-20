module GoCLI
  class Trip
    attr_reader :username, :driver_id, :data
                :start_xpos, :start_ypos, :end_xpos, :end_ypos, :route
                :price

    def self.get_by_username(username)
    end

    def initialize(username, driver_id, start_xpos, start_ypos, end_xpos, end_ypos)
    end

    def details
    end
  end
end