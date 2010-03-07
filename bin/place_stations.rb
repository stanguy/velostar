#! /usr/bin/env ruby1.9 -I../lib

require 'velostar/convert'
require 'velostar/api'
require 'velostar/parse'
require 'velostar/painter'
require 'velostar/rrd'

require '../config.rb'

require 'getoptlong'

if not defined? KEOLIS_API_KEY then
  puts "Can't do anything without an API key"
  exit 1
end
if not defined? CACHE_BASEDIR then
  puts "Can't do much more without a directoy to cache files!"
  exit 1
end

opts = GetoptLong.new(
  [ '--output', '-o', GetoptLong::REQUIRED_ARGUMENT ],
  [ '--start', '-s', GetoptLong::REQUIRED_ARGUMENT ],
  [ '--background', '-b', GetoptLong::REQUIRED_ARGUMENT ]
)
background_id = 2
opts.each do|opt,arg|
  case opt
  when '--output'
    Output_dir = arg
  when '--start'
    Start_time = arg
  when '--background'
    background_id = arg.to_i
  end
end
if ! defined? Output_dir 
  puts "Need an output directory as parameter"
  exit 1
end
if ! File.exist? Output_dir
  puts "The output directory does not exist"
  exit 1
end
Background_Files = [ { 
  :filename => '../map-1.png', 
  :bounds => { :north => 48.1502, :west => -1.723, :east => -1.5872, :south => 48.0769 },
  :size => { :width => 990, :height => 800 } 
}, { 
  :filename => '../rennesz30.png',
  :bounds => { :north => 48.14847 , :west => -1.72531, :south => 48.07711 , :east => -1.56436 },
  :size => { :width => 946, :height => 686 } 
}, {
  :filename => '../map_1280x720.png',
  :bounds => { :north => 48.1405, :west => -1.7270, :east => -1.566, :south => 48.080 },
  :size => { :width => 1280, :height => 720 }
} ]

background = Background_Files[background_id]
if background.nil? then
  puts "Unable to use the requested background"
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

rrd = VeloStar::Rrd.new RRD_BASEDIR
timeline = nil
if ! defined? Start_time
  Start_time = nil
end
list_of_stations.each do |station|
  station[:history] = rrd.fetch station[:id], Start_time
  if timeline.nil?
    timeline = station[:history].keys
  else
    timeline = timeline & station[:history].keys
  end
end

converter = VeloStar::Converter.new VeloStar::Converter::TOP_LEFT, background[:bounds], background[:size]

list_of_stations.each do|station|
  coords = converter.convert( { :x => station[:longitude], :y => station[:latitude] } )
  station[:longitude] = coords[:x]
  station[:latitude] = coords[:y]
end
timestr = ''
timeline.sort.each do |time|
  if 0 == time
    next
  end

  t = Time.at time
  timestr = t.strftime( "%d/%m/%Y %H:%M" )
  
  painter = VeloStar::Painter.new( background )
  
  painter.paint_time_legend timestr

  list_of_stations.each do |station|
    total_slots = station[:history][time][0] + station[:history][time][1]
    percent = station[:history][time][1] / total_slots.to_f
    painter.paint_station( station[:longitude], station[:latitude], percent )
  end
  painter.write( Output_dir + time.to_s + '.png' )
end
