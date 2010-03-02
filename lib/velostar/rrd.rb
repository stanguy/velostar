
module VeloStar
  class Rrd
    def initialize basedir
      @basedir = basedir
    end
    def create id
      system "rrdtool create #{@basedir}#{id}.rrd"
    end
    def update id, value
      system "rrdtool update #{@basedir}#{id}.rrd N:#{value}"
    end
  end
end
