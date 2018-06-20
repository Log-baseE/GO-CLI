module GoCLI
  class User
    USERNAME_PATTERN = /[a-z][a-z0-9_\-]{5,19}/
    USERNAME_PATTERN_DESCRIPTION = <<~DESC
      Username must meet the following conditions:
      - 6-20 characters
      - All alphabet characters must be in lowercase
      - Starts with a letter
      - May only contain alphanumerics, underscore (_) and hyphens(-)
    DESC

    attr_reader :username, :password_digest, :debt
  
    def self.exist?(username)
      
    end
    
    def self.valid_username?(string)
      User::PATTERN.match? username
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