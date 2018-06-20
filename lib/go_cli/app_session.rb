require 'yaml'
require_relative 'world'
require_relative 'utils'
require_relative 'user_session'
require_relative 'driver'
require_relative 'errors'

module GoCLI
  class AppSession
    attr_reader :world, :user_session, :drivers

    def self.load_session_file(filename)
      app_session = Utils.load_file(filename)
      begin
        AppSession.new(
          user_session: app_session.user_session,
          world_size: app_session.world.size,
          drivers: app_session.drivers
        )
      rescue
        raise BadFileError, filename
      end
    end

    def initialize(user_session:, world_size: GoCLI::DEFAULT_WORLD_SIZE, drivers: nil)
      driver_amount = drivers ? drivers.size : GoCLI::DEFAULT_DRIVER_AMOUNT
      min_size = Math.sqrt(driver_amount + 1).ceil
      raise ArgumentError, "World size too small, must be at least #{min_size}" unless world_size >= min_size
      @world = World.new(world_size)
      positions = []
      while positions.size < driver_amount + 1
        pos = []
        loop do
          pos = [rand(1..world_size), rand(1..world_size)]
          break unless positions.include? pos
        end
        positions << pos
      end
      @user_session = user_session
      @drivers = drivers || Driver.sample(driver_amount)
    end
  end
end