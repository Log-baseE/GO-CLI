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
  
    def self.generate_filename(username)
      Config::USER_DATA_DIR + "#{username}.yml"
    end

    def self.exist?(username)
      filename = username + ".yml"
      Utils.load_file(User.generate_filename(username)) ? true : false rescue false
    end
    
    def self.valid_username?(string)
      User::PATTERN.match? username
    end

    def self.valid?(username, password)
      user = load_user_file(User.generate_filename(username))
      user.password_digest == Digest::SHA2.hexdigest(password) rescue false
    end

    def self.load_user_file(filename)
      user = Utils.load_file(filename)
      begin
        User.new(user.username, user.password_digest, user.debt)
      rescue
        raise BadFileError, filename
      end
    end

    def self.signup(username, password)
      user = User.new(username, Digest::SHA2.hexdigest(password), 0)
      filename = generate_filename(username)
      File.new(filename)
      File.write(filename, YAML.dump(user))
      user
    end

    def initialize(username, password_digest, debt)
      @username = username
      @password_digest = password_digest
      @debt = 0
    end

    def add_debt(amount)
      @debt += amount
    end

    private_class_method :generate_filename
  end
end