class SetupService
	require 'Ptv_API'
	include PtvAPI

	def initialize
		@route_sort = Proc.new {|x,y| 
				route_to_s(x) <=> route_to_s(y) 
			}
	end

	def route_to_s(route)
		route_number = !route.route_number.nil? ? route_number = route.route_number+" - ":""
		route_number+route.route_name
	end

	def routes
		routes = []
		Route.all.each {|route|
			routes << route
		}
		routes.sort &@route_sort
		routes
	end

	def routes_for_mode(mode)
		RouteType.find_by(route_type: mode).routes.sort &@route_sort
	end		

	def stops_for_route(route, mode)
		stops = []
		route_type_for_mode = RouteType.find_by(route_type: mode)
		route = Route.where(route_type: route_type_for_mode).find_by(route_id: 1)
		route.stops.sort{|x,y| x.stop_name <=> y.stop_name}
	end

	def directions_for_route(route)
		puts "directions for route: #{route}"
		directions = []
		routes = Route.where(route_id: route)
		routes.each {|r| 
			Direction.where(route: r).each {|d| 
				directions << d
			}
		}
		directions.sort_by{|a| [a.direction_name]}
	end		
end