module GoCLI
  class UserSession
    attr_reader :user
    attr_accessor :xpos, :ypos

    def initialize(username, password)
      user = User.load_data(username, password)
      raise AuthenticationError, "Failed to start user session" unless user
      @user = user
    end

    def do_trip(trip)
      trip.store
      @user.add_debt(trip.price)
      @xpos, @ypos = trip.end_xpos, trip.end_ypos
    end

    def username
      @user.username
    end

    def user_id
      @user.user_id
    end
  end
end