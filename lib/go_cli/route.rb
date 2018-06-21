require 'forwardable'

module GoCLI
  class Route
    extend Forwardable
    
    attr_reader :route
    
    def_delegators :@route, :size, :length, :each, :select, :[], :each_cons

    def self.generate(start_xpos, start_ypos, end_xpos, end_ypos)
      Route.new([start_xpos, start_ypos], [start_xpos, end_ypos], [end_xpos, end_ypos])
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
      @route.each_cons(2) do |node1, node2|
        result += (node2[0] - node1[0]).abs + (node2[1] - node1[1]).abs
      end
      result
    end

    def start_pos
      @route[0]
    end

    def end_pos
      @route[-1]
    end
  end
end