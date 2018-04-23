class RouteType
      # "route_type_name": "Train",
      # "route_type": 0

	attr_accessor :route_type_name, :route_type

	def to_s
		"route_type_name: #{@route_type_name}, route_type: #{@route_type}"
	end
end