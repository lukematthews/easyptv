class CreateExpress

	require 'set'

	def create_all_expresses
		routes = Route.all
		routes.each() {|route|
			puts "#{route.route_name}"
			create_express_for_route(route)
			break
		}
	end

	def create_express_for_route(route)

		# for the route get the runs for each direction.
		Direction.where(route: route).each() {|direction|
			# get the stop order for the route / direction
			stop_order = StopOrder.where(route: route, direction: direction)
			runs = Run.where(route: route, direction_id: direction.id).collect() {|run|
				run.id
			}
			puts "Number of runs: #{runs.size}"
			# for this route and direction, we now have a set of run ids.
			# for each run, get the patterns for those runs.
			Run.where(route: route, direction_id: direction.id).each() {|run|
				puts "process run: #{run.id}"
				process_run(route, direction, stop_order, run)
				break
			}
			break
		}

	end
	
	def process_run(route, direction, stop_order, run)
		# patterns = Pattern.where(run: run, route: route)
		# # having all the patterns for the run means we now know the stops for the run.
		# # for the the patterns, build an array of the stop orders.
		# pattern_stop_orders = patterns.collect { |pattern|
		# 	stop_order.select { |stop|
		# 		puts "pattern stop: #{pattern.stop_id} #{pattern.stop.stop_name} stop_order to check: #{stop.stop_id} #{stop.stop.stop_name}"
		# 		pattern.stop.stop_name == stop.stop.stop_name
		# 	}
		# }
		# puts "stop orders for patterns: #{pattern_stop_orders}"

		# for the run, let's get all the departures. This will then let us build the run times.
		# departures_for_run = Departure.where(run: run)
		# puts "#{run.route_id} #{run.route.id} #{run.route.route_name} #{run.to_s}"
		# puts departures_for_run.size
		# puts
		# routes = departures_for_run.collect {|departure|
		# 	departure.route_id
		# }
		# puts routes.uniq

		patterns_for_run = Pattern.where(run: run)
		patterns_for_run.each {|p| puts p.stop.stop_name + " " + p.scheduled_departure_utc}
		# .each{|pattern| puts pattern.inspect}		
		# puts run.inspect
		# puts Departure.where(run: run).pluck(:route_id).uniq
	end

	def to_local(departure_utc)
		utc_offset = Time.now.getlocal.utc_offset/60/60
		departure_time = DateTime.parse(departure_utc)
		# puts departure_time + (utc_offset/24.0)
		departure_time + (utc_offset/24.0)
	end

end

# CreateExpress.new.create_all_expresses

=begin
# Alamein
route = Route.first
# Get the directions
directions = Direction.where(route: route)

# let's assume where doing the first direction for the route.
direction = directions.first

# Get all the runs for the route (5)
runs = Run.where(route: route, direction: direction)
# Get all the patterns for the runs (135)
patterns = Pattern.where(run: runs)

# Having the patterns gives us the stops.
# we may need to be using the 
# to get the stop_api_id from the patterns...
stop_ids = patterns.collect {|p| p.stop_api_id}.uniq

# now, get all the stop orders for those stops.
StopOrder.where(stop: Stop.where(stop_id: stop_ids), route: route, direction: direction)

# hmm... we now have all the stop order for the route/direction

patterns_for_run.collect{|pat| pat.stop_api_id}.uniq.size

=end

# take 2.
# this should work...

def process_run(run)
	patterns_for_run = Pattern.where(run: run).to_a
	puts "Number of patterns for run: #{run.id}, #{patterns_for_run.size}"
	patterns_for_run = patterns_for_run.uniq { |pattern|
		"#{pattern.stop.stop_name} #{pattern.scheduled_departure_utc}"
	}
	patterns_for_run.each { |pattern|
		puts "#{pattern.id} #{pattern.stop_api_id} #{pattern.stop.stop_name} #{pattern.scheduled_departure_utc}"
		# get the run_time.
		RunTime.where()
	}
end

def process_route(route)
	directions = route.directions
	directions.each { |direction|
		runs = Run.where(route: route, direction: direction)
		patterns = Pattern.where(run: runs)
		stop_ids = patterns.collect { |p| p.stop_api_id}.uniq
		stop_order = StopOrder.where(stop: Stop.where(stop_id: stop_ids), route: route, direction: direction).to_a
		stop_order.sort! { |a,b| a.order <=> b.order }
		stop_order.each { |so| puts so }
		# we now have the all the stops for the route, based on the stop ids in the patterns for all the runs.

		runs.each { |run| process_run(run) }
		break	
	}
end

def create_all
	routes = Route.all()
	routes.each { |route|
		process_route(route)
		break
	}
end

create_all
