

require 'cairo'


module VeloStar
  class Painter
    Colors = [ '#A4DBAC', '#8ED197', '#78C482', '#78C4A2', '#78C4AF', '#8BC1CC',
               '#7AB8C4', '#88BEDB', '#88AFDB', '#888FDB', '#5E67CC', '#3742B3', '#3742B3'  ]
    Outer_color = '#222222'
    Drawing_size = 20
    @overlay_cache = {}
    def initialize background_overlay
      if not defined? @@overlay_cache
        @@overlay_cache = {}
      end
      if not @@overlay_cache.has_key? background_overlay[:filename]
        bgicon = Cairo::ImageSurface.from_png( background_overlay[:filename] )
        @@overlay_cache[background_overlay[:filename]] = bgicon
      end
      @size = background_overlay[:size]
      surface = Cairo::ImageSurface.new( background_overlay[:size][:width], background_overlay[:size][:height] )
      @context = Cairo::Context.new( surface )
      @context.set_source( @@overlay_cache[background_overlay[:filename]] )
      @context.paint
      prepare_surfaces
      paint_legend
    end
    def prepare_surfaces
      if defined? @@color_surfaces
        return
      end
      @@color_surfaces = Colors.collect do |color|
        paint_point color
      end
    end
    def paint_point color
      surface = Cairo::ImageSurface.new( Drawing_size, Drawing_size )
      cr = Cairo::Context.new( surface )
      cr.set_source( 1.0, 1.0, 1.0, 0.0 )
      paint_circle cr, Drawing_size/2, Drawing_size/2, Drawing_size, color
      return surface
    end
    def paint_circle( cr, x, y, diameter, color )
      cr.set_source_color( color )
      cr.save
      cr.translate( x, y )
      cr.scale( diameter/2, diameter/2 );
      cr.arc( 0, 0, 1, 0, Math::PI * 2 )
      cr.restore
      cr.fill
      cr.stroke
      # and now, around
      cr.set_source_color( Outer_color )
      cr.save
      cr.translate( x, y )
      cr.scale( diameter/2, diameter/2 );
      cr.arc( 0, 0, 1, 0, Math::PI * 2 )
      cr.restore
      cr.stroke
    end
    Legend_width = 20
    Legend_height = 20

    def paint_legend
      # paint something about the colors used
      nb_colors = Colors.length
      if not defined? @@legend_overlay
        surface = Cairo::ImageSurface.new( nb_colors * Legend_width, Legend_height )
        cr = Cairo::Context.new( surface )
        Colors.each_with_index do|color,idx|
          cr.set_source_color color
          cr.rectangle( idx*Legend_width, 0, Legend_width, Legend_height )
          cr.fill
          cr.stroke
        end
        cr.set_source_color Outer_color
        cr.rectangle( 0, 0, Legend_width * nb_colors, Legend_height )
        cr.stroke
        cr.target.write_to_png "/tmp/leg.png"
        @@legend_overlay = surface
      end
      @context.set_source( @@legend_overlay, @size[:width] - Legend_width * ( nb_colors + 1 ), Legend_height )
      @context.paint
    end
    def paint_time_legend str
      @context.set_source_color( '#111111' );
      @context.save
      @context.move_to( @size[:width]-180, @size[:height]-15  )
      @context.select_font_face( 'monospace', 'normal', 'bold' );
      @context.set_font_size( 18 );
      @context.show_text( str );
      @context.stroke
      @context.restore
    end
    def paint_station( x, y, value )
      color_idx = (value*(Colors.length-1)).round
      @context.set_source( @@color_surfaces[color_idx], x, y )
      @context.paint
    end
    def write filename
      @context.target.write_to_png( filename )
    end
  end
end
