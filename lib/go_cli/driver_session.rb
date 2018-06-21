module GoCLI
  class DriverSession
    attr_reader :driver, :driver_id
    attr_accessor :xpos, :ypos
    
    def initialize(driver_id, x, y)
      @driver_id = driver_id
      @driver = Driver.load_data(driver_id)
      @xpos, @ypos = x, y
    end

    def details
      details = <<~DETAIL
        Name\t\t  : #{@driver.name}
        License plate\t  : #{@driver.license_plate}
        Rating\t\t  : #{"%.1f" % @driver.rating}
        Currently at\t  : (#{@xpos}, #{@ypos})
      DETAIL
    end

    def encode_with(coder)
      vars = instance_variables.map(&:to_s)
      vars -= ['@driver']
      vars.each { |var| coder[var.gsub('@', '')] = eval(var) }
    end
  end
end