#! /usr/bin/env ruby1.9 -I ../lib

require 'velostar/rrd'

require "test/unit"
require 'mocha'
 
class TestVeloStarRrd < Test::Unit::TestCase
  Test_id = 12
  Basedir = '/tmp/'
  Test_timestart = 1267655513
  Test_path = "testpath"
  def test_filename
    rrd = VeloStar::Rrd.new Basedir
    assert_equal "#{Basedir}#{Test_id}.rrd", rrd.get_filename( Test_id )
  end
  def test_creation
    rrd = VeloStar::Rrd.new Basedir
    rrd.expects(:system).with("rrdtool create #{Basedir}#{Test_id}.rrd DS:slots:GAUGE:600:0:50 DS:bikes:GAUGE:600:0:50 RRA:AVERAGE:0.5:1:2016").once
    rrd.create( Test_id )
  end
  def test_creation_custom_rra
    rrd = VeloStar::Rrd.new Basedir
    rrd.expects(:system).with("rrdtool create #{Basedir}#{Test_id}.rrd DS:slots:GAUGE:600:0:50 DS:bikes:GAUGE:600:0:50 a b").once
    rrd.create( Test_id, ["a", "b" ] )
  end
  def test_update
    rrd = VeloStar::Rrd.new Basedir
    rrd.expects(:system).with("rrdtool update -t slots:bikes #{Basedir}#{Test_id}.rrd N:1:2").once
    rrd.update( Test_id, 1, 2 )
  end
  def test_fetch
    rrd = VeloStar::Rrd.new Basedir
    rrd.expects(:`#` emacs is broken here 
                ).with("rrdtool fetch #{Basedir}#{Test_id}.rrd AVERAGE").once.returns("   slots   bikes\n\n1267804800: 2.8134873133e+01 1.8651268667e+001267805100: 3.0000000000e+01 0.0000000000e+00\n1267805400: 3.0000000000e+01 0.0000000000e+00\n")
    ret = rrd.fetch( Test_id )
    assert_kind_of Hash, ret
    ret.keys.each do |k|
      assert_kind_of Integer, k
      assert_kind_of Array, ret[k]
    end
  end
  def test_fetch_with_start_time
    rrd = VeloStar::Rrd.new Basedir
    rrd.expects(:`#` emacs is broken here 
                ).with("rrdtool fetch #{Basedir}#{Test_id}.rrd -s #{Test_timestart} AVERAGE").once.returns("   slots   bikes\n\n1267804800: 2.8134873133e+01 1.8651268667e+001267805100: 3.0000000000e+01 0.0000000000e+00\n1267805400: 3.0000000000e+01 0.0000000000e+00\n")
    ret = rrd.fetch( Test_id, Test_timestart )
  end
  def test_create_with_different_path()
    rrd = VeloStar::Rrd.new Basedir, Test_path
    rrd.expects(:system).with("#{Test_path} create #{Basedir}#{Test_id}.rrd DS:slots:GAUGE:600:0:50 DS:bikes:GAUGE:600:0:50 RRA:AVERAGE:0.5:1:2016").once
    rrd.create( Test_id )
  end
      
end
