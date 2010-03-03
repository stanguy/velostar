#! /usr/bin/env ruby -I../lib

require 'velostar/api'

require "test/unit"
require 'mocha'

# module Net
#   class HTTP
#   end
# end
 
class TestVeloStarApi < Test::Unit::TestCase
  Test_key = "THISISATEST"
  Test_uri = "http://data.keolis-rennes.com/xml/?version=1.0&key=#{Test_key}&cmd=getstation"
  def test_getstations
    api = VeloStar::Api.new Test_key
    empty_body_result = '<apikr><request></request></apikr>'
    result_mock = mock('Net::HTTPResponse')
    result_mock.stubs(:code => '200', 
                      :message => "OK", 
                      :content_type => "text/html", 
                      :body => empty_body_result )
    test_uri = URI.parse(Test_uri)
    Net::HTTP.stubs(:get_response).with(test_uri).returns(result_mock).once
    res = api.getstation
    assert_equal res, empty_body_result
  end
end
