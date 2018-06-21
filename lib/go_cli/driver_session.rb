module GoCLI
  class DriverSession
    attr_reader :driver
    attr_accessor :xpos, :ypos
    
    def initialize(driver_id, x, y)
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

    def driver_id
      @driver.driver_id
    end
  end
end