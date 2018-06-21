module GoCLI
  class World
    attr_reader :size
    
    def valid_coordinate?(x,y)
      (1..@size).include?(x) && (1..@size).include?(y)
    end

    def initialize(size)
      @size = size
    end
  end
end