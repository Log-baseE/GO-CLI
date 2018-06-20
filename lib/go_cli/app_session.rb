module GoCLI
  class AppSession
    attr_reader :world, :user_session, :drivers

    def self.load_file(filename)
    end

    def initialize(user_session, world_size: GoCLI::DEFAULT_WORLD_SIZE, drivers: nil)
    end
  end
end