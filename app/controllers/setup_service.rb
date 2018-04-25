class SetupService
	require 'Ptv_API'
	include PtvAPI

	require_relative '../models/json/route_type_model'
	require_relative '../models/json/route_model'
	require_relative '../models/json/stop_model'
	require_relative '../models/json/direction_model'

	def modes
		modes = []
		data = run("/v3/route_types?")
		data["route_types"].each do |route_type|
			r = RouteType.new
			r.route_type_name = route_type["route_type_name"]
			r.route_type = route_type["route_type"]
			modes << r
		end
		modes
 #      "route_type_name": "Train",
 #      "route_type": 0
	end

    # {
    #   "route_type": 1,
    #   "route_id": 887,
    #   "route_name": "West Maribyrnong - Flinders Street Station & City",
    #   "route_number": "57"
    # },

	def routes
		routes = []
		data = run("/v3/routes?")
		data["routes"].each do |route|
			r = Route.new
			r.route_type = route["route_type"]
			r.route_id = route["route_id"]
			r.route_name = route["route_name"]
			r.route_number = route["route_number"]
			routes << r
		end
		routes.sort {|x,y| x.to_s <=> y.to_s }
		routes
	end

	def routes_for_mode(mode)
		routes = []
		data = run("/v3/routes?route_types=#{mode}&")
		data["routes"].each do |route|
			r = Route.new
			r.route_type = route["route_type"]
			r.route_id = route["route_id"]
			r.route_name = route["route_name"]
			r.route_number = route["route_number"]
			r.display_name = r.to_s
			routes << r
		end
		routes = routes.sort {|x,y| x.display_name <=> y.display_name }
		routes
	end		

	def stops_for_route(route, mode)
		# http://timetableapi.ptv.vic.gov.au/v3/stops/route/12/route_type/0?devid=3000522&signature=8DC154E32B5D95FDCDAD2DD650494818122BAA18
		    #   "stop_name": "Balaclava Station",
		    #   "stop_id": 1013,
		    #   "route_type": 0,
		    #   "stop_latitude": -37.8694878,
		    #   "stop_longitude": 144.993515
		puts "#{mode}, #{route}"
		stops = []
		data = run("/v3/stops/route/#{route}/route_type/#{mode}?")
		data["stops"].each do |stop|
			s = StopModel.new
			s.stop_name = stop["stop_name"]
			s.stop_id = stop["stop_id"]
			s.route_type = stop["route_type"]
			s.stop_latitude = stop["stop_latitude"]
			s.stop_longitude = stop["stop_longitude"]
			s.display_name = s.to_s
			stops << s
		end
		stops
	end

	def directions_for_route(route)
		# http://timetableapi.ptv.vic.gov.au/v3/directions/route/12?devid=3000522&signature=75431521EB677051015D0A2D4450FE75BAEDDC31
		    # {
		    #   "direction_id": 1,
		    #   "direction_name": "City (Flinders Street)",
		    #   "route_id": 12,
		    #   "route_type": 0
		    # },
		puts "directions for route: #{route}"
		directions = []
		data = run("/v3/directions/route/#{route}?")
		puts "data for directions: #{data}"
		data["directions"].each do |direction|
			d = DirectionModel.new
			d.direction_id = direction["direction_id"]
			d.direction_name = direction["direction_name"]
			d.route_id = direction["route_id"]
			d.route_type = direction["route_type"]
			d.display_name = d.to_s
			directions << d
		end
		directions
	end		

end