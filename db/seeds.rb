# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

require_relative '../db/create_run_times'
require_relative '../db/progress_monitor'

require 'Ptv_API'
include PtvAPI

def route_types
	# RouteType.destroy_all()
	data = run("/v3/route_types?")
	data["route_types"].each { |rt| 
		RouteType.create(
			route_type: rt["route_type"], 
			route_type_name: rt["route_type_name"])
	}
	puts "Created #{RouteType.all.size} route types"
end

def direction(route_model)
	data = run("/v3/directions/route/#{route_model.route_id}?")
	data["directions"].each {|direction|
		Direction.create(
			direction_id: direction["direction_id"],
			direction_name: direction["direction_name"],
			route_api_id: direction["route_id"],
			# route_type_api_id: direction["route_type"],
			route: route_model,
			route_type: route_model.route_type
			)
	}
end

def routes
	# Direction.destroy_all
	# Route.destroy_all
	# Stop.destroy_all
	
	file = File.read("app/assets/reference/map_urls-2.json")
	route_maps = JSON.parse(file)

	# routes = Route.all
	# routes.each {|route|
	# 	json_route = route_maps[route.route_id.to_s]
	# }

	rt = RouteType.all

	data = run("/v3/routes?")
	routes_count = data["routes"].size

	puts "Creating #{routes_count} routes (and directions,stops)"

	p = ProgressMonitor.new(routes_count)

	data["routes"].each { |route|

		route_type_model = rt.select { |route_type|
				route_type.route_type.to_s == route["route_type"].to_s
			}.first
		route_model = Route.create(
			route_type: route_type_model,
			route_type_api_id: route["route_type"],
			route_id: route["route_id"],
			route_name: route["route_name"],
			route_number: route["route_number"],
			route_gtfs_id: route["route_gtfs_id"])

		json_route = route_maps[route["route_id"].to_s]
		if !json_route.nil?	
			route_model.map_url = json_route["map_url"]
			route_model.save
		else
# puts "#{route_maps}"
			puts " #{route['route_id']} not found in json"
		end

		direction(route_model)
		stop(route_model)

		p.increment
	}
end

def stop(route_model)
	data = run("/v3/stops/route/#{route_model.route_id}/route_type/#{route_model.route_type.route_type}?")
	data["stops"].each{|stop|
		Stop.create(
			stop_id: stop["stop_id"],
			stop_name: stop["stop_name"],
			route_type_api_id: stop["route_type"],
			route_type: route_model.route_type,
			route: route_model,
			stop_suburb: stop["stop_suburb"],
			station_type: stop["station_type"],
			station_description: stop["station_description"]
			)
	}
end

def runs
	# Run.destroy_all
	routes = Route.all

	p = ProgressMonitor.new(routes.size)
	puts "Loading all runs for routes"

	routes.each {|route|
		data = run("/v3/runs/route/#{route.route_id}?")
		data["runs"].each{|run|
			
			#get direction for direction_id (with a bit of luck, this column should be indexed)
			direction_model = Direction.find_by(
				direction_id: run["direction_id"])

			Run.create(
				run_id: run["run_id"],
				route_api_id: run["route_id"],
				route_type_api: run["route_type"],
				final_stop_id: run["final_stop_id"],
				destination_name: run["destination_name"],
				status: run["status"],
				direction_api_id: run["direction_id"],
				run_sequence: run["run_sequence"],
				express_stop_count: run["express_stop_count"],
				route: route,
				direction: direction_model,
				route_type: route.route_type
				)
		}
		p.increment
	}
end

def departures
	# Departure.destroy_all

	stops = Stop.all

	p = ProgressMonitor.new(stops.size)

	puts "Loading all departures (for stops - #{stops.size})"

	stops.each { |stop|
		data = run("/v3/departures/route_type/#{stop.route_type.route_type}/stop/#{stop.stop_id}?")
		# puts "departures for stop: #{data['departures'].size} stop: #{stop.stop_name}"
		data["departures"].each{|departure|

			direction_model = Direction.find_by(direction_id: departure["direction_id"])
			route_model = Route.find_by(route_id: departure["route_id"])
			run_model = Run.find_by(run_id: departure["run_id"])

			Departure.create(
				stop_id: departure["stop_id"],
				stop_api_id: departure["stop_id"],
				route_id: departure["route_id"],
				route_api_id: departure["route_id"],
				run_id: departure["run_id"],
				run_api_id: departure["run_id"],
				direction_id: departure["direction_id"], 
				direction_api_id: departure["direction_id"],
				scheduled_departure_utc: departure["scheduled_departure_utc"],
				estimated_departure_utc: departure["estimated_departure_utc"], 
				at_platform: departure["at_platform"],
				platform_number: departure["platform_number"],
				flags: departure["flags"],
				departure_sequence: departure["departure_sequence"],
				stop: stop,
				direction: direction_model,
				route: direction_model.route,
				run: run_model
				)



		}
		p.increment
	}
end

def patterns
	# Pattern.destroy_all
	runs = Run.all

	puts "Loading patterns for all runs (#{runs.size})"
	p = ProgressMonitor.new(runs.size)

	runs.each {|run|

		# puts "Pattern api call: /v3/pattern/run/#{run.run_id}/route_type/#{run.route_type}?"
		data = run("/v3/pattern/run/#{run.run_id}/route_type/#{run.route_type.route_type}?")
		# p "Pattern departures from api: #{data['departures'].size}"
		data["departures"].each{|pattern_run|

			stop_model = Stop.find_by(stop_id: pattern_run["stop_id"])

			# p "Creating pattern for run: #{pattern_run['run_id']}"
			Pattern.create(
				stop_id: pattern_run["stop_id"],
				route_id: pattern_run["route_id"],
				run_id: pattern_run["run_id"],
				scheduled_departure_utc: pattern_run["scheduled_departure_utc"], 
				estimated_departure_utc: pattern_run["estimated_departure_utc"],
				at_platform: pattern_run["at_platform"],
				platform_number: pattern_run["platform_number"],
				flags: pattern_run["flags"],
				departure_sequence: pattern_run["departure_sequence"],
				stop_api_id: pattern_run["stop_id"],
				route_api_id: pattern_run["route_id"],
				run_api_id: pattern_run["run_id"],
				run: run,
				stop: stop_model,
				route: run.route
				)
		}
		p.increment
	}
end



# Delete all the data in the following order. The order needs to start from
# children first, all the way up to parents.
# We need to do this to not violate foreign key constraints.

# Departure.destroy_all
# Pattern.destroy_all
# Run.destroy_all
# Stop.destroy_all
# Direction.destroy_all
# Route.destroy_all
# RouteType.destroy_all



# Load all the data in the following order

# route_types
# routes 	# routes, directions, stops
# runs 		# for all the routes, load their runs.
##### (handled by create_run_times for the moment...)  departures
# patterns

# This one is a little bit more interesting.
#   For the time table we need the scheduled times in
#   M-F, hh:mm (local time) format

TimeProcessor.new.load_all_departures
