

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
      x = point[:x]
      y = point[:y]
      # change origin
      x = x - @bounds[:west]
      y = y - @bounds[:north]
      # scale
      x = x * ( @new_bounds[:width] / ( @bounds[:east] - @bounds[:west] ) )
      y = y * ( @new_bounds[:height] / ( @bounds[:south] - @bounds[:north] ) )
      { :x => x, :y => y }
    end
  end
end
