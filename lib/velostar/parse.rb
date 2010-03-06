
require 'hpricot'

module VeloStar

  class Parse
    def parse_stations fh
      stations = []
      
      doc = Hpricot.parse fh
      doc.search("/apikr/answer/data/station") do|el|
        stations << {
          :id => el.search("number")[0].innerText,
          :latitude => el.search("latitude")[0].innerText.to_f,
          :longitude => el.search("longitude")[0].innerText.to_f,
          :bikes => el.search("bikesavailable")[0].innerText.to_i,
          :slots => el.search("slotsavailable")[0].innerText.to_i,
          :has_pos? =>  ( el.search("pos")[0].innerText.to_i == 1 )
        }
      end

      return stations
    end
  end
end
