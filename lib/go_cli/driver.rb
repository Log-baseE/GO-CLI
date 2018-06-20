module GoCLI
  class Driver
    attr_reader :driver_id, :name, :license_plate, :rating

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
      driver = Driver.new(driver_id, name, license_plate, Config::MAX_RATING)

      Utils.write_file(driver, filename)
      driver_id_map = Utils.load_yml_file(Config::USER_ID_MAPFILE)
      driver_id_map << driver_id
      Utils.write_yml_file(driver_id_map, Config::USER_ID_MAPFILE)
      driver_file_map = Utils.load_yml_file(Config::USER_FILE_MAPFILE)
      driver_file_map << filename
      Utils.write_yml_file(driver_file_map, Config::USER_FILE_MAPFILE)
      driver
    end

    def self.load_file(filename)
      driver = Utils.load_file(filename)
      begin
        Driver.new(driver.driver_id, driver.name, driver.license_plate, driver.rating)
      rescue
        raise BadFileError, filename
      end
    end

    def initialize(driver_id, name, license_plate, rating)
      @driver_id = driver_id
      @name = name
      @license_plate = license_plate
      @rating = rating
    end

    def encode_with(coder)
      vars = instance_variables.map(&:to_s)
      vars -= ['@xpos', '@ypos']
      vars.each { |var| coder[var.gsub('@', '')] = eval(var) }
    end

    def update_rating
    end
  end
end