module GoCLI
  class Driver
    attr_reader :driver_id, :name, :license_plate, :rating, :filename

    def self.generate_id(name, license_plate)
      Digest::SHA1.hexdigest("#{name}#{license_plate}")
    end

    def self.generate_filename(name, license_plate)
      driver_id = self.generate_id(name, license_plate)
      Config::DRIVER_DATA_DIR + "#{driver_id}.yml"
    end

    def self.create(name, license_plate)
      driver_id = Driver.generate_id(name, license_plate)
      filename = Driver.generate_filename(name, license_plate)
      driver = Driver.new(driver_id, name, license_plate, Config::MAX_RATING, filename)

      driver.store
      driver
    end

    def self.load_data(driver_id)
      driver_file_map = Utils.load_yml_file(Config::DRIVER_FILE_MAPFILE)
      filename = driver_file_map[driver_id]
      Driver.load_driver_file(filename)
    end

    def self.load_driver_file(filename)
      driver = Utils.load_file(filename)
      begin
        Driver.new(driver.driver_id, driver.name, driver.license_plate, driver.rating, driver.filename)
      rescue
        raise BadFileError, filename
      end
    end

    def self.random_sample(amount)
      driver_id_list = Utils.load_yml_file(Config::DRIVER_ID_MAPFILE)
      driver_id_list.sample(amount)
    end

    def self.valid_rating?(rating)
      # puts (Config::MIN_RATING..Config::MAX_RATING)
      (Config::MIN_RATING..Config::MAX_RATING).include? rating
    end

    def store
      Utils.write_file(self, @filename)
      driver_id_map = Utils.load_yml_file(Config::DRIVER_ID_MAPFILE)
      driver_id_map << @driver_id
      Utils.write_yml_file(driver_id_map, Config::DRIVER_ID_MAPFILE)
      driver_file_map = Utils.load_yml_file(Config::DRIVER_FILE_MAPFILE)
      driver_file_map[@driver_id] = filename
      Utils.write_yml_file(driver_file_map, Config::DRIVER_FILE_MAPFILE)
    end

    def initialize(driver_id, name, license_plate, rating, filename = nil)
      @driver_id = driver_id
      @name = name
      @license_plate = license_plate
      @rating = rating
      @filename = filename
    end

    def encode_with(coder)
      vars = instance_variables.map(&:to_s)
      vars -= ['@xpos', '@ypos']
      vars.each { |var| coder[var.gsub('@', '')] = eval(var) }
    end

    def update_rating(rating)
      # puts rating.class
      @rating = rating
      store
    end
  end
end