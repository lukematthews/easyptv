class GenerateStopOrders  
	require_relative '../lib/Ptv_API'
	include PtvAPI

	# require_relative '../lib/stop_order_3'
	require_relative '../lib/stop_sorter'

	require 'date'
	require 'json'
	require 'set'

	require_relative '../app/models/json/departure_model'
	require_relative '../app/models/json/departures_model'
	require_relative '../app/models/json/direction_model'
	require_relative '../app/models/json/pattern_model'
	require_relative '../app/models/json/route_model'

	def create_stop_order
		stops_for_routes = []

		route_counter = 0

		# Load all the routes
		routes = routes()
		routes.each do |route|

			route_counter += 1

# Early testing bail out. Stop at 10 routes.
# print "\n\r#{route_counter}"
# if route_counter == 10
# 	break
# end
			so_route = SORoute.new
			so_route.route_id = route.route_id
			# Get the runs for the route. This allow us to get the patterns.
			# get the directions for the route
			directions = directions_for_route(route.route_id)
			# stops_for_direction = []
			directions.each do | direction |
				# stops_for_direction << process_direction_for_route(route, direction)
				sorted_stops = process_direction_for_route(route, direction)

				so_direction = SODirection.new
				so_direction.direction_id = direction.direction_id
				so_direction.stops = sorted_stops
				so_route.directions << so_direction
			end
			stops_for_routes << so_route
		end
		p stops_for_routes
		StopWriter.new.write_stops_to_file(stops_for_routes)
	end

	def process_direction_for_route(route, direction)
		# Get the runs
		runs = run("/v3/runs/route/#{route.route_id}?")

		# Get the runs for the direction.
		runs_for_direction = runs["runs"].select {
			|run|
				run["direction_id"] == direction.direction_id
		}

		pattern_stops = Set[]

	    print "\nNumber of runs for route #{route} direction #{direction}: #{runs_for_direction.length}\n"
	    counter = 0
		runs_for_direction.each do |run|

			# Get the patterns for the run
			# This is where it gets interesting
			run_patterns = patterns_for_run(run["run_id"], route.route_type)
			
			# The patterns for run go in multiple directions, 
			# let's just focus on the direction we want.
			run_patterns.select {|pattern|
				pattern["direction_id"] == direction.direction_id
			}

# early loop stop.
# if counter == 50
# 	break
# end

			# A pattern has an array of departures each with a direction id.
			# run_patterns only contains the patterns for our direction.

			# Given the patterns, create an array of the stop id's 
			# for the patterns
			pattern_stops << create_stopping_patterns(run_patterns)

			percentage = counter/runs_for_direction.length.to_f
			percentage = percentage * 100.0
			counter+=1
			printf("\r%d/#{runs_for_direction.length} %.2f\%", 
				counter, percentage)
		end

		# ok, we've got the stops for the direction. 
		# Let's sort them into a single list.
		sorted_stops = []
		# (pattern_stops is an array of Set's, convert it into an array.)
		pattern_stops = pattern_stops.to_a

		(0..pattern_stops.length-1).each do |list_index|
			StopSorter.new.sort_list(sorted_stops, pattern_stops[list_index])
		end

		sorted_stops
	end

	def create_stopping_patterns(run_patterns)
		stopping_patterns_for_runs = []
		run_patterns.each do | pattern_departure |
			stop = pattern_departure["stop_id"]
			stopping_patterns_for_runs << stop
		end
		stopping_patterns_for_runs
	end

	def process_patterns(run_patterns, stop_order)
		# run_patterns is the departures array. The order of elements is the stopping order. Well, it should be.
		# Let's make an array of the stop ids.

		pattern_stops = []

		run_patterns.each do |departure|
			pattern_stops << departure["stop_id"]
    	end

    	pattern_stops
	end

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

	def directions_for_route(route)
		directions = []
		data = run("/v3/directions/route/#{route}?")
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

	def patterns_for_run(run, route_type)
		# get all the patterns for the route/direction. (from the run id)
		uri = "/v3/pattern/run/#{run}/route_type/#{route_type}?"
		data = run(uri)
		data["departures"]
	end

	def stop_name(stop_id, route_type)
		data = run("/v3/stops/#{stop_id}/route_type/#{route_type}?")
		data["stop"]["stop_name"]
	end
end


class SORoute
	attr_accessor :route_id
	attr_accessor :directions

	def initialize
		@directions = []
	end

	def to_json(*args)
		{'route_id' => @route_id, 'directions' => @directions}.to_json(*args)
	end
end

class SODirection
	attr_accessor :direction_id
	attr_accessor :stops

	def initialize
		@stops = []
	end

	def to_json(*args)
		{'direction_id'=> @direction_id, 'stops'=>@stops}.to_json(*args)
	end
end

class StopWriter
	def write_stops_to_file(route_stops)
		File.open("stop_order.json","w") do |f|
		  f.write(JSON.pretty_generate(route_stops))
		end
	end
end

