

module VeloStar
  class Converter
    TOP_LEFT    = 1
    BOTTOM_LEFT = 2

    def initialize origin_position, source_bounds, target_size
      @bounds = source_bounds
      @new_bounds = target_size
      @way = origin_position
    end
    def convert point
      if not ( point[:x].between?( @bounds[:west], @bounds[:east] ) and
               point[:y].between?( @bounds[:south], @bounds[:north] ) )
        raise RangeError
      end
      { :x => (point[:x] - @bounds[:west])*@new_bounds[:width], :y => (point[:y]-@bounds[:north])*(-1*@new_bounds[:height]) }
    end
  end
end
