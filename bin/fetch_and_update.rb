#! /usr/bin/env ruby -I../lib

require '../config.rb' # this is were the key should be defined

if not defined? KEOLIS_API_KEY then
  puts "Can't do anything without an API key"
  exit 1
end
if not defined? RRD_BASEDIR then
  puts "Can't do much more without a directoy to put my RRD files, bro!"
  exit 2
end

require 'velostar/parse'
require 'velostar/rrd'
require 'velostar/api'

api = VeloStar::Api.new KEOLIS_API_KEY
remote_data = api.getstation
parser = VeloStar::Parse.new
list_of_stations = parser.parse_stations remote_data

rrd = VeloStar::Rrd.new RRD_BASEDIR
list_of_stations.each do|station|
  if not File.exists?( rrd.get_filename( station[:id] ) ) then
    rrd.create station[:id]
  end
  rrd.update station[:id], station[:slots], station[:bikes]
end

