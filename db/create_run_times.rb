class TimeProcessor

	require_relative '../db/progress_monitor'
	require 'Ptv_API'
	include PtvAPI

	@directions
	@routes
	@runs

	def initialize
		@directions = {}
		@routes = {}
		@runs = {}
	end

	# What are we saving here?
	# - Departures
	# - RunDays
	# - RunTimes


	# route_type, route, stop, direction...
	# Train, Alamein, Alamein, To ciry...
	# 0,1,1002,1

	# Take the scheduled departure time (in UTC) and parse it. Given that
	# parsed date, return the name of the day of the week.
	# DateTime.strptime(dep.scheduled_departure_utc).strftime("%A")
	def load_all_departures
		RouteType.all.each{|route_type|
		# RouteType.all.each{|route_type|
			puts "Loading run times for route type: #{route_type.route_type_name}"

#			found_routes = route_type.routes.each()
			found_routes = route_type.routes.where("id = 829")
			# found_routes = route_type.routes.where("id not in (select distinct route_id from run_days) and id not in (992)")

			r_m = ProgressMonitor.new(found_routes.size)
			
			# route_type.routes.each {|route|
			found_routes.each() {|route|
				puts "Loading run times for route: #{route.route_name}"
				route.stops.each {|route_stop|
					puts "Loading run times for stop: #{route_stop.stop_name}"
					route.directions.each {|direction|
						puts "Loading run times for direction: #{route_stop.stop_name} - #{direction.direction_name}"
						load_for(route, route_stop, direction)
					}
				}
				r_m.increment
			}
		}
	end

	def load_for(ro, st, dir)

		create_run_days(ro, st, dir)

		deps = []
		today = Date.today
		day_monitor = ProgressMonitor.new(8)
		(0..7).each { |day_to_load|
			# Load all the departures for the stop/day. These will then need to be saved to the database.
			new_deps = departures(st.route_type, st, dir, today+day_to_load)
			new_deps.each { |dep_item| 
				dep_item.save
				deps << dep_item
			}
			day_monitor.increment
		}

		# Given all the departures we've just created, create the run times
		# for them.
		# p = ProgressMonitor.new(deps.size)
		deps.each {|dep|
			departure_time = to_local(dep.scheduled_departure_utc)
	
			runDay = RunDay.find_by(
				route: ro, 
				stop: st, 
				direction: dir, 
				day_name: get_day_name(departure_time)
				)

			# get the hours and the minutes from the time.
			hour = departure_time.hour
			minute = departure_time.min

			# Is the time already in the times for the run day?
			contains = runDay.run_times.detect {|time|
				time.hour == hour && time.minutes == minute
			}
			if contains.nil?
				# The time is not in the times for the run day. Create it.
				RunTime.create(
					run_day: runDay,
					hour: hour,
					minutes: minute)
			end
			# p.increment
		}
	end

	def get_day_name(departure_time)
		case departure_time.cwday
		when 6
			return RunDay::SAT
		when 7
			return RunDay::SUN
		else
			return RunDay::MF
		end
	end

	def to_local(departure_utc)
		utc_offset = Time.now.getlocal.utc_offset/60/60
		departure_time = DateTime.parse(departure_utc)
		# puts departure_time + (utc_offset/24.0)
		departure_time + (utc_offset/24.0)
	end

	def create_run_days(ro, st, dir)
		RunDay.create(
			route: ro, 
			stop: st, 
			direction: dir, 
			day_name: RunDay::MF)
		RunDay.create(
			route: ro, 
			stop: st, 
			direction: dir, 
			day_name: RunDay::SAT)
		RunDay.create(
			route: ro, 
			stop: st, 
			direction: dir, 
			day_name: RunDay::SUN)

	end

	def stop(route_model)
		data = run("/v3/stops/route/#{route_model.route_id}/route_type/#{route_model.route_type.route_type}?")
		stops = []
		data["stops"].each{|stop|
			model_stop = Stop.new
			model_stop.stop_id = stop["stop_id"],
			model_stop.stop_name = stop["stop_name"],
			model_stop.route_type_api_id = stop["route_type"],
			model_stop.route_type = route_model.route_type,
			model_stop.route = route_model,
			model_stop.stop_suburb = stop["stop_suburb"],
			model_stop.station_type = stop["station_type"],
			station_description = stop["station_description"]
			stops << model_stop
		}
	end

	def departures(route_type, stop, dir, time)

		departures = []
		formatted_date = time.strftime("%Y-%m-%dT00:00")
		# stops.each { |stop|
		data = run("/v3/departures/route_type/#{route_type.route_type}/stop/#{stop.stop_id}?direction_id=#{dir.direction_id}&date_utc=#{formatted_date}&")
		# puts "departures for stop: #{data['departures'].size}"

		# Try and reduce the number of database hits.
		# Cache the direction, route and runs.
		directions = {}
		routes = {}
		runs = {}

		# p = ProgressMonitor.new(data['departures'].size)

		data["departures"].each{|departure|

			direction_id = departure["direction_id"]
			direction = @directions[direction_id] || Direction.find_by(direction_id: departure["direction_id"])
			@directions[direction_id] = direction

			route_id = departure["route_id"]
			route = @routes[route_id] || Route.find_by(route_id: route_id)
			@routes[route_id] = route

			run_id = departure["run_id"]
			run = runs[run_id] || Run.find_by(run_id: run_id)
			@runs[run_id] = run

			departure_model = Departure.new
			departure_model.scheduled_departure_utc = departure["scheduled_departure_utc"]
			departure_model.estimated_departure_utc = departure["estimated_departure_utc"]
			departure_model.at_platform = departure["at_platform"]
			departure_model.platform_number = departure["platform_number"]
			departure_model.flags = departure["flags"]
			departure_model.departure_sequence = departure["departure_sequence"]
			departure_model.stop = stop
			departure_model.direction = direction
			departure_model.route = route
			departure_model.run = run

			departure_model.stop_api_id = departure["stop_id"]
			departure_model.route_api_id = departure["route_id"]
			departure_model.run_api_id = departure["run_id"]
			departure_model.direction_api_id = departure["direction_id"]

			departures << departure_model
			# p.increment
		}
		return departures
	end
end



# route_type, route, stop, direction...
# Train, Alamein, Alamein, To ciry...
# 0,1,1002,1
# route_type = RouteType.find_by(route_type_name: "Train")
# route = Route.find_by(route_id: 1)
# stop = Stop.find_by(stop_id: "1002")
# direction = Direction.find_by(direction_id: "1")	
# TimeProcessor.new.load_for(route_type, route, stop, direction)

def test_load

	# disable logging
	old_logger = ActiveRecord::Base.logger
	ActiveRecord::Base.logger = nil

	rt = RouteType.find_by(route_type_name: "Train")
	st = Stop.find_by(stop_name: "Alamein Station")

	processor = TimeProcessor.new
	# For each of the directions, create all the run times.
	st.route.directions.each {|direction|
		# there will be 2 directions here, but because it is the last stop on the
		# line, there will only be times for 1.
		processor.load_for(st.route, st, direction)
	}
end

# PTV questions...
# ref 2018-198271 (7 business days)



