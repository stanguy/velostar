#! /usr/bin/env ruby -I../lib

require 'velostar/api'
require 'velostar/parse'

require '../config.rb'

if not defined? KEOLIS_API_KEY then
  puts "Can't do anything without an API key"
  exit 1
end
if not defined? CACHE_BASEDIR then
  puts "Can't do much more without a directoy to cache files!"
  exit 1
end

Stations_cache = CACHE_BASEDIR + 'stations.xml'
list_of_stations = nil
parser = VeloStar::Parse.new
if File.exist? Stations_cache
  list_of_stations = parser.parse_stations File.open Stations_cache
else
  api = VeloStar::Api.new KEOLIS_API_KEY
  remote_data = api.getstation
  list_of_stations = parser.parse_stations remote_data
  File.open Stations_cache, "w" do |file|
    file.write remote_data
  end
end


times = { 1278835800.to_s => "", 'end-1w' => "_weekly", 'end-4w' => "_monthly", 'end-1d' => "_daily" }

defs = []
# graph each
list_of_stations.each do |station|
  st_defs = { "slots" + station[:id] => "DEF:slots#{station[:id]}=#{RRD_BASEDIR}/#{station[:id]}.rrd:slots:AVERAGE", 
    "bikes" +station[:id] => "DEF:bikes#{station[:id]}=#{RRD_BASEDIR}/#{station[:id]}.rrd:bikes:AVERAGE" }
  times.each do |start_time,extension|
    system( "rrdtool", "graph", 
            "../export/#{station[:id]}#{extension}.png", 
            "-w", "300", 
            "--color", "SHADEA#FFF", "--color", 'SHADEB#FFF', 
            "--color", 'GRID#FFFFFF00', "--color", 'MGRID#FFFFFF00', 
            "--color", 'BACK#FFF',
            "-s", start_time, 
            st_defs.values[0], st_defs.values[1], 
            "AREA:bikes#{station[:id]}#3742B3:Velos disponibles", "AREA:slots#{station[:id]}#A4DBAC:Emplacements disponibles:STACK" )
  end
  defs.push st_defs
end

times.each do |start_time,extension|
  args = [ "rrdtool", "graph",
           "../export/all#{extension}.png",
           "-w", "300",
           "-s", start_time ]
  args.concat defs.collect { |d| d.values }.flatten
  [ "slots", "bikes" ].each do |t|
    compute_ar = defs.collect {|d| d.keys }.flatten.grep Regexp.new( t )
    compute_ar.concat ((compute_ar.size - 1).times.collect { '+' })
    args << "CDEF:#{t}=" + compute_ar.join( "," )
  end
  args.concat( [ "AREA:bikes#3742B3:Velos disponibles", "LINE:slots#A4DBAC:Emplacements disponibles"])
  system( *args )
end
