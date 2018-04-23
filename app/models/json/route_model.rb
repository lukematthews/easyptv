class Route

    # {
    #   "route_type": 1,
    #   "route_id": 887,
    #   "route_name": "West Maribyrnong - Flinders Street Station & City",
    #   "route_number": "57"
    # },

    attr_accessor :route_type, :route_id, :route_name, :route_number, :display_name

    def display_name
        to_s
    end

    def to_s
    	output = ""
    	if @route_number.to_s.empty? == false
    		output = "#{@route_number} -"
    	end
    	output = "#{output} #{@route_name}"
    	output
    end
end