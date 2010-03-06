#! /usr/bin/env ruby -I../lib

require 'velostar/convert'

require "test/unit"
require 'mocha'

class TestVeloStarConverter < Test::Unit::TestCase
  Test_bounds = { :west => -1, :north => 48, :east => 0, :south => 47 }
  Test_canvas_size = { :width => 800, :height => 600 }
  def setup
    @conv = VeloStar::Converter.new VeloStar::Converter::TOP_LEFT, Test_bounds, Test_canvas_size
  end
  def test_origin
    res = @conv.convert( { :x => Test_bounds[:west], :y => Test_bounds[:north] })
    assert_equal res, { :x => 0, :y => 0 }
  end
  def test_oob_left
    assert_raise( RangeError ) {
      @conv.convert( { :x => Test_bounds[:west] -1, :y => Test_bounds[:north] } )
    }
  end
  def test_lowerleft
    res = @conv.convert( { :x => Test_bounds[:west], :y => Test_bounds[:south] } )
    assert_equal( { :x => 0, :y => Test_canvas_size[:height] }, res )
  end
  def test_upperright
    res = @conv.convert( { :x => Test_bounds[:east], :y => Test_bounds[:north] } )
    assert_equal( { :x => Test_canvas_size[:width], :y => 0 }, res )
  end
  def test_lowerright
    res = @conv.convert( { :x => Test_bounds[:east], :y => Test_bounds[:south] } )
    assert_equal( { :x => Test_canvas_size[:width], :y => Test_canvas_size[:height] }, res )
  end    
  def test_middle
    res = @conv.convert( :x => ( Test_bounds[:east].to_f + Test_bounds[:west].to_f ) / 2,
                         :y => ( Test_bounds[:south].to_f + Test_bounds[:north].to_f ) / 2 )
    assert_equal( { :x => Test_canvas_size[:width]/2, :y => Test_canvas_size[:height] / 2 }, res )
  end
end
