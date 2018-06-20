module GoCLI
  class UserSession
    attr_reader :user
    attr_accessor :xpos, :ypos

    def initialize(username, password)
      user = User.load_data(username, password)
      raise AuthenticationError, "Failed to start user session" unless user
      @user = user
    end

    def do_trip(driver_id, dest_xpos, dest_ypos)
      Trip.new(@user.username, driver_id, @xpos, @ypos, dest_xpos, dest_ypos)
      @xpos, @ypos = dest_xpos, dest_ypos
    end
  end
end