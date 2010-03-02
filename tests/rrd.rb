#! /usr/bin/env ruby1.9 -I ../lib

require 'velostar/rrd'

require "test/unit"
require 'mocha'
 
class TestVeloStarRrd < Test::Unit::TestCase
  Test_id = 12
  Basedir = '/tmp/'
  def test_filename
    rrd = VeloStar::Rrd.new Basedir
    assert_equal "#{Basedir}#{Test_id}.rrd", rrd.get_filename( Test_id )
  end
  def test_creation
    rrd = VeloStar::Rrd.new Basedir
    rrd.expects(:system).with("rrdtool create #{Basedir}#{Test_id}.rrd").once
    rrd.create( Test_id )
  end
  def test_update
    rrd = VeloStar::Rrd.new Basedir
    rrd.expects(:system).with("rrdtool update #{Basedir}#{Test_id}.rrd N:1:2").once
    rrd.update( Test_id, 1, 2 )
  end
end
