module GoCLI
  class UserSession
    attr_reader :user
    attr_accessor :xpos, :ypos

    def initialize(username, password, xpos: nil, ypos: nil)
    end

    def add_trip(dest_xpos, dest_ypos)
    end
  end
end