class TimetableService

	require 'Ptv_API'
	include PtvAPI

	require 'date'
	require 'base64'
	require 'json'
	require 'net/http'
	require 'openssl'

	@route_type
	@stop
	@direction_id

	@deps

	@public_holidays

	def initialize
		@public_holidays = []
		@deps = Departures.new
	end

	def routeName()
		@routeName
	end

	def directionName()
		@destination
	end
	
	def stopName()
		@stopName
	end

	def publicHolidays()
		@public_holidays
	end

	def loadRouteDetails(route_api_id)
		route = Route.find_by(route_id: route_api_id)
		@routeName = route.route_name
		@routeTypeId = route.route_type.route_type
		routeNumber = route.route_number

		# Train: "#{routeName} Line"
		# Tram: "Route #{routeNumber}"
	 	case @routeTypeId 
	 	when 0
	 		@routeName = "#{@routeName} Line"
	 	when 1
	 		@routeName = "Route #{routeNumber}"
	 	when 2
	 		@routeName = "Route #{routeNumber}"
	 	end
	 	@routeName
	end

	def loadDirectionDetails(route_type, route_id, direction_id)
		direction = getDirectionDetails(route_type, route_id, direction_id)
		@route_id = direction[:route]
		@destination = direction[:direction_name]
	end

	def getDirectionDetails(route_type, route_id, direction_id)
		dir = Direction.where(
			direction_id: direction_id, 
			route_type: RouteType.find_by(route_type: route_type), 
			route: Route.find_by(route_id: route_id)).first
		Hash[:route => dir.route.route_id, 
				:direction_name => dir.direction_name]
	end

	def getStopName(route_type, stop_id)
		rt = RouteType.find_by(route_type: route_type)
		Stop.where(stop_id: stop_id, route_type: rt).first.stop_name
	end

	def loadStopName(route_type, stop_id)
		@stopName = getStopName(route_type, stop_id)
	end

	def loadDeparturesToStop(route_type, route_id, stop, direction_id, end_stop)
		# Once we get the departures, we can load the patterns for each departure (run), 
		# this will give us the time the run will be stopping there.

		# I guess we will need to load the run/arrival time into TimeModel.
		# Time: 43 min
		# Arrival @ <Stop>: hh:mm

		# Do we want to exclude the time or highlight it in another colour 
		# if the service doesn't stop at the end stop?

		# If we load the run_id into a set, we can load the patterns and determine 
		# what time the run gets to the end_stop. To make sure we don't load too many patterns,
		# store the run_id's into a set and only load the distinct runs/patterns
		start_stop = stop
		loadAll(route_type, route_id, start_stop, direction_id, end_stop, true)
	end

	#"yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"
	def loadDepartures(route_type, route_id, stop, direction_id)
		loadAll(route_type, route_id, stop, direction_id, 0, false)
	end

	def loadAll(route_type, route_id, stop, direction_id, destination, loadTimes)
		@route_type = route_type
		@stop = stop
		@direction_id = direction_id

		# Three calls here to get more information about the timetable.
		#  * Which route is it? (Name and Number)
		#  * What direction is it going? (Name)
		#  * What stop is it? (Name)

		# Get the route name for the route id.
		loadRouteDetails(route_id)

		# Get direction name for the direction id
		loadDirectionDetails(route_type, route_id, direction_id)
		
		# Get the stop name for the stop id.
		stop = getStopName(route_type, stop)
		@stopName = stop

		#  For the next 7 days (week)
		now = Date.today

		# Public holidays.
		# 	Is the day being loaded a public holiday?
		# 	If so, what is the holiday name and what timetable is in effect?
		# 	Do not load the departure into the new departures array. UNLESS... The day is a Saturday or Sunday, in which case, we want the times.

		@deps.departures = []
		days_to_load = (0..7).to_a

		days_to_load.each { |day|
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
				# Load the days timetable and load it into the departures array
				departure_times = loadDay(dayToLoad)
				puts "Adding departure time: #{departure_times}"
				@deps.departures << departure_times
			end
		}

		days = Hash.new
		# days {"M_F" times {hour, [minutes]}], "SAT"..., "SUN"...}
		# iterate through all the departures...
		@deps.departures.each { |day|
			day.each { |day_data|
				local = getDateFromLocalString(day_data.scheduled_departure_utc)

# p "#{day_data.scheduled_departure_utc} - #{local}"

				time = local.to_time
				# get the DayModel for the day.
				case local.cwday
				when 6
					day_name = "Saturday"
				when 7
					day_name = "Sunday"
				else
					day_name = "Monday to Friday"
				end

				time_model = TimeModel.new
				time_model.hour = time.hour
				time_model.minutes = time.min
				time_model.run_id = day_data.run_id

				day_model = days[day_name]
				if day_model.nil?
					day_model = DayModel.new
				end

				day_model.day_name = day_name
				times = day_model.times
				if (times.nil?)
					times = SortedSet.new
				else
					# This feels really unnatural - sorted set works on object instance,
					# using a to_s which only has the time in it allows it to work

					# This effectively serializes the time model as a string 
					# so that it can be unique and sorted

					# HOW DO I ADD THE RUN ID FROM THE DEPARTURE INTO THIS?
					# MAYBE A HASH WITH THE TIMES MAPPED TO THE RUN_ID's?

					times.add(time_model.to_s)
				end
				day_model.times = times
				days[day_name] = day_model

				if (day_model.runs[time_model.to_s].nil?)
					day_model.runs[time_model.to_s] = SortedSet.new
				end
				day_model.runs[time_model.to_s] << day_data.run_id
			}
		}

		days
		# build view model for timetable page.
		# day: "Monday to Friday", am: (collection of hours, each hour contains its minutes), pm:
		# day methods:
		#  getDisplayHour(24hr) (or hour - 12 if greater than 12.)
		#  isLastHour(24hr)

#		puts @deps.departures


# {"departures":[
	# {"stop_id":12400,
	# "route_id":7700,
	# "run_id":58479,
	# "direction_id":220,
	# "disruption_ids":[],
	# "scheduled_departure_utc":"2018-04-11T19:36:00Z",
	# "estimated_departure_utc":null,
	# "at_platform":false,
	# "platform_number":null,
	# "flags":""}

	end

	def loadDay(date)

		formattedDate = CGI::escape(date.strftime("%Y-%m-%dT00:00"))
		# route_type_pattern = "route_type/#{@route_type}"
		# stop_pattern = "stop/#{@stop}"
		# date_pattern = "date_utc=#{formattedDate}"
		# direction_pattern = "direction_id=#{@direction_id}"

		# uri = "/v3/departures/#{route_type_pattern}/#{stop_pattern}?#{direction_pattern}&#{date_pattern}&"

		# This is calling module methods
		# data = parsed_json(execute(uri))
		# data = run(uri)

		routeType = 
		stop = Stop.where(
				route_type: RouteType.find_by(route_type: @route_type), 
				stop_id: @stop).first
		direction = Direction.find_by(direction_id: @direction_id)
		departures = Departure.where(
			route: stop.route,
			stop: stop,
			direction: direction)

		puts "Loaded departures: #{departures.size}"

		return departures
		# newDepartures = []
		# data['departures'].map { |dep|
		# 	if dep['route_id'] == @route_id
		# 		# d = Departure.new
		# 		# d.stop_id = dep['stop_id']
		# 		# d.route_id = dep['route_id']
		# 		# d.run_id = dep['run_id']
		# 		# d.direction_id = dep['direction_id']
		# 		# d.scheduled_departure_utc = dep['scheduled_departure_utc']
		# 		newDepartures << d
		# 	end
		# }
		# newDepartures
	end

	def departures
		@deps.departures
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

	def format_duration(duration)
		seconds = 86400*duration
		one_hour = 60*60
		time = Time.at(seconds).utc
		format_string = "%-H hours %-M minutes"
		# Is the duration less than an hour?
		if (seconds < one_hour) 
			format_string = "%-M minutes"		
		elsif (seconds < one_hour + 60)
			format_string = "%-H hour"
		elsif seconds < one_hour + (60*2)
			format_string = "%-H hour %-M minute"
		else
			format_string = "%-H hours %-M minutes"		
		end
		time.strftime(format_string)		
	end
	
	def processRun(route_type, startStop, endStop, run)
		# Load the pattern.
		uri = "/v3/pattern/run/#{run}/route_type/#{route_type}?"
		data = run(uri)

		start_time = Date.new.to_s		
		end_time = Date.new.to_s

		# Iterate over the departures, looking for the stops. 
		# Capture the departures for the start and end stop.
		stops = []
		running = false
		data['departures'].map { |dep|
			time = dep['scheduled_departure_utc']
			stop = dep['stop_id'].to_i
			if stop == startStop.to_i
				# Capture the start time of the pattern
				start_time = time
				running = true
			elsif stop == endStop.to_i
				# Capture the end time of the pattern
				end_time = time
				running = false
			end
			if running
				stopping_at = getStopName(route_type, stop)
				stops << stopping_at
			end
		}

		# Get the local times of both the start and the end times.
		start_time = getDateFromLocalString(start_time)
		end_time = getDateFromLocalString(end_time)

		# end_time - start_time = number of seconds difference as a rational.
		# eg 1/240 = 86400 * (1/240) = 362.88 = 00:06, which is the trip length.
		trip_length = end_time - start_time # This is a rational fraction of the day. 6 min = 1/240
		stats = [start_time, end_time, trip_length, stops]
	end

	def getDateFromLocalString(departure_date)
		d = DateTime.parse(departure_date)
		getDepartureDateLocal(d)
	end

	def getDepartureDateLocal(departureDate)
		# This works if the local time of the server is AET/AEDT
		# utc_offset = Time.now.localtime.utc_offset

		# 10 for AET
		utc_offset = 10
		# 11 for AEDT
		# utc_offset = 11

		local = departureDate +	 (utc_offset/24.0)
		local
	end


end

# Formatting the way the sets print
class Set
	def to_s
		to_a.join(', ')
	end
end