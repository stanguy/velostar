#! /usr/bin/env ruby1.9 -I../lib

require 'velostar/convert'
require 'velostar/api'
require 'velostar/parse'
require 'velostar/rrd'

require '../config.rb'

require 'cairo'
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
  [ '--start', '-s', GetoptLong::REQUIRED_ARGUMENT ]
)
opts.each do|opt,arg|
  case opt
  when '--output'
    Output_dir = arg
  when '--start'
    Start_time = arg
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
} ]

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

background = Background_Files[1]

bgicon = Cairo::ImageSurface.from_png( background[:filename] )

Colors = { 
  :plenty_of_bikes => '#2810B0',
  :equal => '#23A6B8',
  :plenty_of_slots => '#8FCF42'
}
Drawing_size = 20

converter = VeloStar::Converter.new VeloStar::Converter::TOP_LEFT, background[:bounds], background[:size]

list_of_stations.each do|station|
  coords = converter.convert( { :x => station[:longitude], :y => station[:latitude] } )
  station[:longitude] = coords[:x]
  station[:latitude] = coords[:y]
end
reftime = nil
timestr = ''
timeline.sort.each do |time|
  if 0 == time
    next
  end

  if reftime.nil? || ( 0 == ( time % 3600 ) )
    t = Time.at time
    timestr = t.strftime( "%d/%m/%Y %H:%M" )
    reftime = time
  end

  Cairo::ImageSurface.new( background[:size][:width], background[:size][:height] ) do |surface|
  
    cr = Cairo::Context.new(surface)

    cr.set_source( bgicon )
    cr.paint

    cr.set_source_color( '#111111' );
    cr.save
    cr.move_to( 10, 10 )
    cr.select_font_face( 'monospace', 'normal', 'normal' );
    cr.set_font_size( 12 );
    cr.show_text( timestr );
    cr.stroke
    cr.restore


    list_of_stations.each do |station|
      total_slots = station[:history][time][0] + station[:history][time][1]
      percent = station[:history][time][1] * 100 / total_slots
      if percent > 75 
        color = Colors[:plenty_of_bikes]
      elsif percent < 25
        color = Colors[:plenty_of_slots]
      else
        color = Colors[:equal]
      end
      cr.set_source_color(color)
      #    cr.rectangle( coords[:x] - Drawing_size/2, coords[:y] - Drawing_size/2, Drawing_size, Drawing_size )
      cr.save
      cr.translate( station[:longitude]+Drawing_size/2, station[:latitude]+Drawing_size/2 )
      cr.scale( Drawing_size/2, Drawing_size/2 );
      cr.arc( 0, 0, 1, 0, Math::PI * 2 )
      cr.restore
      cr.fill
      cr.stroke
    end

    cr.target.write_to_png( Output_dir + time.to_s + '.png' )
  end
end
