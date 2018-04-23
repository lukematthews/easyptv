class TimetableService

	require 'Ptv_API'
	include PtvAPI

	require 'date'
	require 'base64'
	require 'json'
	require 'net/http'
	require 'openssl'

	require_relative '../models/json/departure_model'
	require_relative '../models/json/departures_model'

	@route_type
	@stop
	@direction_id

	@devid
	@key

	@deps

	@public_holidays

# DayModel is setup on line 136.

# we need to be able to return info on the public holidays in effect.

	def initialize

		@public_holidays = []
		@deps = Departures.new

# These need to be passed in as URL parameters
		@route_type = "2"
		@stop = "12400"
		@direction_id = "222"

# These are constants
		@devid = "3000522"
		@key = 	"9b321181-e0b4-4e9d-b08a-5af3d26bb6fc"
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

	def loadRouteDetails(route_id)
		data = run("/v3/routes/#{route_id}?")
		@routeName = data["route"]["route_name"]
		routeNumber = data["route"]["route_number"]

		# Train: "#{routeName} Line"
		# Tram: "Route #{routeNumber}"
	 	case @routeTypeId 
	 	when "0"
	 		@routeName = "#{@routeName} Line"
	 	when "1"
	 		@routeName = "Route #{routeNumber}"
	 	when "2"
	 		@routeName = "Route #{@routeNumber}"
	 	end
	end

	def loadDirectionDetails(route_type, route_id, direction_id)
		data = run("/v3/directions/#{direction_id}?")
		directions = data["directions"]
		directions.each do |d|
			r = d["route_id"]
			rt = d["route_type"]
			if (r.to_s == route_id.to_s && rt.to_s == route_type.to_s)
				@route_id = r
				@destination = d["direction_name"]
			end
		end
	end

	def loadStopName(route_type, stop)
		data = run("/v3/stops/#{stop}/route_type/#{route_type}?")
		@stopName = data["stop"]["stop_name"]
	end

	#"yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"
	def loadDepartures(route_type, route_id, stop, direction_id)

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
		loadStopName(route_type, stop)

		#  For the next 7 days (week)
		now = Date.today

		@deps.departures = []
		(1..7).to_a.each do |day|
			dayToLoad = now+day

			localDay = getDepartureDateLocal(dayToLoad)

			isPublicHoliday = @deps.is_public_holiday(localDay)
			if isPublicHoliday
				@public_holidays << @deps.getHoliday(localDay)
			end
			sat_or_sun = false
			sat_or_sun = localDay.cwday == 6 || localDay.cwday == 7

			# If its not a public holiday, add it.
			# Or, if it's a SAT/SUN and a public holiday, add it. 
			if (!isPublicHoliday || (isPublicHoliday && sat_or_sun))
			# 	# Load the days timetable and load it into the departures array
				@deps.departures << loadDay(dayToLoad)
			end

		end


		days = Hash.new

		# days {"M_F" times {hour, [minutes]}], "SAT"..., "SUN"...}
		# iterate through all the departures...
		@deps.departures.each do |day|
			day.each do |day_data|
				local = getDepartureDateLocal(day_data.departureUTC)
# well this sucks... date + utc_offset = add utc_offset number of days. sigh.
#				local = day_data.departureUTC + 36000
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
				
				day_model = days[day_name]
				if day_model.nil?
					day_model = DayModel.new
				end

				day_model.day_name = day_name
				times = day_model.times
				if (times.nil?)
					times = SortedSet.new
				else
					# This feels really unnatural
					times.add(time_model.to_s)
				end
				day_model.times = times
				days[day_name] = day_model
			end
		end

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

# Public holidays.
# 	Is the day being loaded a public holiday?
# 	If so, what is the holiday name and what timetable is in effect?
# 	Do not load the departure into the new departures array. UNLESS... The day is a Saturday or Sunday, in which case, we want the times.

		formattedDate = CGI::escape(date.strftime("%Y-%m-%dT00:00"))
		route_type_pattern = "route_type/#{@route_type}"
		stop_pattern = "stop/#{@stop}"
		date_pattern = "date_utc=#{formattedDate}"
		direction_pattern = "direction_id=#{@direction_id}"

		uri = "/v3/departures/#{route_type_pattern}/#{stop_pattern}?#{direction_pattern}&#{date_pattern}&"

# p uri
# uri = "/v3/departures/route_type/#{@route_type}/stop/#{@stop}?date_utc=#{formattedDate}&direction_id=#{@direction_id}"
# /v3/departures/route_type/2/stop/12400?date_utc=2018-04-12T00:00&direction_id=220
# add this after the signature has been created "&devid=3000522&signature=84FFBF8344A992DC3D45081C30632077BC97A9AC"

		# This is calling module methods
		# data = parsed_json(execute(uri))
		data = run(uri)

		newDepartures = []

# Not needed... run() parses the json now.
		# data = JSON.parse(data)
		data['departures'].map { |dep|
			if dep['route_id'] == @route_id
				d = Departure.new
				d.stop_id = dep['stop_id']
				d.route_id = dep['route_id']
				d.run_id = dep['run_id']
				d.direction_id = dep['direction_id']
				d.scheduled_departure_utc = dep['scheduled_departure_utc']
				newDepartures << d
			end
		}

		newDepartures
	end

	def departures
		@deps.departures
	end

	def getDepartureDateLocal(departureDate)
		utc_offset = Time.now.localtime.utc_offset
		local = departureDate + Rational(utc_offset, 86400)
		local
	end
end

# Formatting the way the sets print
class Set
	def to_s
		to_a.join(', ')
	end
end