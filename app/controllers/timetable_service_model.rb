class TimetableServiceModel

	attr_reader :route_name, :stop_name, :direction_name, :public_holidays
	@route_name
	@stop_name
	@direction_name

	def initialize
		@public_holidays = []
	end

	def loadDepartures(route, stop, direction)
		@route_name = route.route_name
		@stop_name = stop.stop_name
		@direction_name = direction.direction_name

		# no destination, don't load the times...
		loadAll(route, stop, direction, false)
	end

	def loadDeparturesToStop(route, stop, direction, end_stop)
		loadAll(route, stop, direction, end_stop, true)
	end

	def loadAll(route, stop, direction, destination, loadTimes = false)

		# route_type, route, stop, direction should all be activerecords.
		days = RunDay.where(route: route, stop: stop, direction: direction)
		# create a hash using the day_name as the key.
		deperatures = {}
		days.each {|day|
			deperatures[day.day_name] = day
		}

		# ok, we've got the run_days which have got the times... now.
		# So, what the original copy did was create a hash of 'times' for the day.
		# This has then had the run_ids for the time. These run ids are then used
		# by the view to load the patterns. 

		

		return deperatures
	end

	def process_public_holidays
		@public_holidays = []
		(0..7).each { |day|
			dayToLoad = now+day
			local_day = getDepartureDateLocal(dayToLoad)

			isPublicHoliday = @deps.is_public_holiday(local_day)
			if isPublicHoliday
				@public_holidays << @deps.getHoliday(local_day)
			end
			sat_or_sun = false
			sat_or_sun = local_day.cwday == 6 || local_day.cwday == 7

			# If its not a public holiday, add it.
			# Or, if it's a SAT/SUN and a public holiday, add it. 
			if (!isPublicHoliday || (isPublicHoliday && sat_or_sun))
				# it's a monday to friday that's not a public holiday.
			end

		}
	end

	def loadTimes(route_type, startStop, endStop, runs)

		# Runs is a comma separated id list... make it an array...
		runs = runs.split(", ")

		departure = Time.new
		earliest_arrival = Date.new
		latest_arrival = Date.new
		min_duration = 0
		max_duration = 0

		stops = []

		# times...	{ :run_id => [:start, :end, :trip_length, :arrival]
		# 			}
		times = Hash.new {}
		runs.each_with_index() do |run,index|
			run_times = processRun(route_type, startStop, endStop, run)
			if index == 0
				departure = run_times[0]
				earliest_arrival = run_times[1]
				latest_arrival = run_times[1]
				min_duration = run_times[2]
				max_duration = run_times[2]
			else 
				# Departure time is the earliest departure time.
				# run_times[0] < departure ? departure = run_times[0]
				departure = run_times[0] < departure ? run_times[0] : departure

				run_times[1] < earliest_arrival ? earliest_arrival = run_times[1] : earliest_arrival
				run_times[1] > latest_arrival ? latest_arrival = run_times[1] : latest_arrival

				run_times[2] < min_duration ? min_duration = run_times[2] : min_duration
				run_times[2] > max_duration ? max_duration = run_times[2] : max_duration
			end

			stops << run_times[3]

			times[run] = run_times
		end

		# trip_length = seconds(as a rational), convert it into a hh:mm string
		# if trip length
		trip_length = Time.at(86400 * trip_length.to_f).utc.strftime("%H hours %M min")


		# Pattern is the object to be returned in json.
		travel_time = PatternModel.new

		# Departure time:
		travel_time.departure = departure.strftime("%l:%M%P")

		# Stops
		travel_time.stops = stops.flatten.uniq

		# Convert it to "hh hours mm minutes" or "mm minutes" if less than an hour.
		if min_duration == max_duration
			travel_time.duration = format_duration(min_duration)
		else
			travel_time.min_duration = format_duration(min_duration)
			travel_time.max_duration = format_duration(max_duration)
		end

		if travel_time.earliest_arrival == travel_time.latest_arrival
			travel_time.arrival = earliest_arrival.strftime("%l:%M%P")
		else
			travel_time.earliest_arrival = earliest_arrival.strftime("%l:%M%P")
			travel_time.latest_arrival = latest_arrival.strftime("%l:%M%P")
		end

		travel_time
	end
end
