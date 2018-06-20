module GoCLI
  class World
    attr_reader :size
    
    def initialize(size)
      @size = size
    end

    def valid_coordinate?(x,y)
      (1..@size).include?(x) && (1..@size).include?(y)
    end
  end
end