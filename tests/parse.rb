#! /usr/bin/env ruby1.9 -I../lib

require 'velostar/parse'

require "test/unit"
require 'mocha'
 
class TestVeloStarParse < Test::Unit::TestCase
  Test_file = 'data_full.xml'
  Test_file_nb_stations = 80
  def test_global_parsing
    parser = VeloStar::Parse.new
    ret = parser.parse_stations File.open Test_file
    assert_instance_of Array, ret
    assert_equal Test_file_nb_stations, ret.length
    ret.each do|s|
      assert s.has_key?(:id), "no id entry"
      assert s.has_key?(:latitude), "no latitude entry"
      assert_kind_of Float, s[:latitude]
      assert s.has_key?(:slots), "no slots entry"
      assert_kind_of Integer, s[:slots]
      assert s.has_key?(:bikes), "no bikes entry"
      assert s.has_key?(:has_pos?), "no has_pos? entry"
      assert((s[:has_pos?] === true || s[:has_pos?] === false), "pos is boolean")
    end
  end
end
