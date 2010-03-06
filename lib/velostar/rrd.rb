
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
      system "rrdtool update -t slots:bikes #{get_filename id} N:#{slots}:#{bikes}"
    end
    def fetch id, starttime = nil
      args = [ "rrdtool", "fetch", get_filename(id) ]
      if not starttime.nil?
        args.push "-s"
        args.push starttime
      end
      args.push "AVERAGE"
      fetch_output = `#{args.join " "}`
      data = {}
      fetch_output.each_line do |line|
        if line.match /nan/
          next
        end
        f = line.split( / +/ )
        if 3 != f.length
          next
        end
        data[f[0].to_i] = [ f[1].to_f, f[2].to_f ]
      end
      data
    end
  end
end
