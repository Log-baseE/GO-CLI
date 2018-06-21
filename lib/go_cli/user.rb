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

    attr_reader :user_id, :username, :password_digest, :debt, :filename

    def self.generate_id(username)
      Digest::SHA1.hexdigest(username)
    end

    def self.generate_filename(username)
      user_id = User.generate_id(username)
      Config::USER_DATA_DIR + "#{user_id}.yml"
    end

    def self.exist?(username)
      user_id_map = Utils.load_yml_file(Config::USER_ID_MAPFILE)
      user_id_map[username] ? true : false rescue false
    end
    
    def self.valid_username?(string)
      User::USERNAME_PATTERN.match? string
    end

    def self.valid?(username, password)
      return false unless User.exist?(username)
      user = load_user_file(User.generate_filename(username))
      user.password_digest == Digest::SHA2.hexdigest(password) rescue false
    end

    def self.load_data(username, password)
      return nil unless User.valid?(username, password)
      user_id_map = Utils.load_yml_file(Config::USER_ID_MAPFILE)
      user_id = user_id_map[username]
      user_file_map = Utils.load_yml_file(Config::USER_FILE_MAPFILE)
      filename = user_file_map[user_id]
      User.load_user_file(filename)
    end

    def self.load_user_file(filename)
      user = Utils.load_file(filename)
      begin
        User.new(user.user_id, user.username, user.filename, user.password_digest, user.debt)
      rescue
        raise BadFileError, filename
      end
    end

    def store
      Utils.write_file(self, @filename)
      user_id_map = Utils.load_yml_file(Config::USER_ID_MAPFILE)
      user_id_map[@username] = @user_id
      Utils.write_yml_file(user_id_map, Config::USER_ID_MAPFILE)
      user_file_map = Utils.load_yml_file(Config::USER_FILE_MAPFILE)
      user_file_map[@user_id] = @filename
      Utils.write_yml_file(user_file_map, Config::USER_FILE_MAPFILE)
      self
    end

    def self.signup(username, password)
      user_id = User.generate_id(username)
      filename = User.generate_filename(username)
      user = User.new(user_id, username, filename, Digest::SHA2.hexdigest(password), 0)
      user.store
    end

    def initialize(user_id, username, filename, password_digest, debt)
      @user_id = user_id
      @username = username
      @filename = filename
      @password_digest = password_digest
      @debt = 0
    end

    def add_debt(amount)
      @debt += amount
      store
    end

    def to_s
      puts @password_digest
    end
  end
end