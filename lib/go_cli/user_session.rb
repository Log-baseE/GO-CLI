module GoCLI
  class UserSession
    attr_reader :user, :username
    attr_accessor :xpos, :ypos

    def initialize(username, password)
      user = User.load_data(username, password)
      raise AuthenticationError, "Failed to start user session" unless user
      @user = user
      @username = username
    end

    def do_trip(trip)
      @user.add_debt(trip.price)
      @xpos, @ypos = trip.end_xpos, trip.end_ypos
    end

    def user_id
      @user.user_id
    end

    def encode_with(coder)
      vars = instance_variables.map(&:to_s)
      vars -= ['@user', '@username']
      vars.each { |var| coder[var.gsub('@', '')] = eval(var) }
    end
  end
end