
module VeloStar
  class Rrd
    def initialize basedir
      @basedir = basedir
    end
    def get_filename id
      "#{@basedir}#{id}.rrd"
    end
    def create id
      filename = get_filename id
      system "rrdtool create #{get_filename id} DS:slots:GAUGE:600:0:50 DS:bikes:GAUGE:600:0:50 RRA:AVERAGE:0.5:1:2016"
    end
    def update id, slots, bikes
      system "rrdtool update #{get_filename id} N:#{slots}:#{bikes}"
    end
  end
end
