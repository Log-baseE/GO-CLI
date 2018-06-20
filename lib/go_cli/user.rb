module GoCLI
  class User
    attr_reader :username, :password_digest, :debt
  
    def self.exist?(username)
    end

    def self.valid?(username, password)
    end

    def self.load_file(filename)
    end

    def self.signup(username, password)
    end

    def initialize(username, password_digest, debt)
    end

    def add_debt(amount)
    end
  end
end