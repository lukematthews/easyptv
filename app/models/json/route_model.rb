class Route

    # {
    #   "route_type": 1,
    #   "route_id": 887,
    #   "route_name": "West Maribyrnong - Flinders Street Station & City",
    #   "route_number": "57"
    # },

    attr_accessor :display_name, :route_type, :route_id, :route_name, :route_number

    def display_name
        to_s
    end

    def to_s
    	output = @route_number.to_s.empty? ? "" : "#{@route_number} - "
    	"#{output} #{@route_name}"
    end
end