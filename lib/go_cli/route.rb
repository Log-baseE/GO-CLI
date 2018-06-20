require 'forwardable'

module GoCLI
  class Route
    extend Forwardable
    
    attr_reader :route
    
    def_delegators :@route, :size, :length, :each, :select, :[]

    def self.generate(start_xpos, start_ypos, end_xpos, end_ypos)
      Route.new([start_xpos, start_ypos], [end_xpos, end_ypos])
    end
    
    def initialize(startpos, nextpos, *nodes)
      unless
        startpos.is_a?(Array) && startpos.size == 2 && startpos[0].is_a?(Integer) && startpos[1].is_a?(Integer) && 
        nextpos.is_a?(Array) && nextpos.size == 2 && nextpos[0].is_a?(Integer) && nextpos[1].is_a?(Integer) && 
        nodes.all? { |node| node.is_a?(Array) && node.size == 2 && node[0].is_a?(Integer) && node[1].is_a?(Integer)}
        raise ArgumentError, "Expected all arguments to be [Integer, Integer]s"
      end
      @route = ([] << startpos << nextpos) + nodes
    end

    def distance
      result = 0
      prev = @route[0]
      @route[1..@route.size].each do |node|
        result += (node[0] - prev[0]).abs + (node[1] - prev[1]).abs
        prev = node
      end
      result
    end
  end
end