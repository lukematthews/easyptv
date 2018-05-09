class TimetableController < ApplicationController

	require 'cgi'

  helper_method :generate_title

	@dayViewModelMF
	@dayViewModelSAT
	@dayViewModelSUN

	@publicHolidays
	@has_public_holiday

	@routeId
	@stopId
	@directionId

	@hello

	def index
		# This should really be using ids instead of names.
		# using ids means we can get the names from the api (similar to the setup page)
		@routeTypeId = params[:route_type]
		@routeId = params[:route]
		@stopId = params[:stop]
		@directionId = params[:direction]

		t = TimetableService.new
		days = t.loadDepartures(@routeTypeId, @routeId, @stopId, @directionId)

		setTimes(t, days)

		setPageClasses()

		# Save this as the first search and move the others down the list.
		# If this is already in the list, remove the existing one and have this at the top.
		saveCookie("timetable")

		render 
	end

	def withDepartures
		@routeTypeId = params[:route_type]
		@routeId = params[:route]
		@stopId = params[:stop]
		@directionId = params[:direction]
		# Destination is the stop id of where the arrival times and trip length are calculated to.
		@destination = params[:destination]
		@end_stop_id = params[:destination]
		t = TimetableService.new
		
		@end_stop = t.getStopName(@routeTypeId, @destination)

		days = t.loadDeparturesToStop(@routeTypeId, @routeId, @stopId, @directionId, @end_stop)

		setTimes(t, days)

		setPageClasses()

		render
	end

	def recentSearches

		# The value of the cookie is a json [] containing a hash of the search parameters and the search type (arrival/withDepartures) (this comes from the params object)
		# Parse the search parameters to create a url and name of the search
		view_data = []

		(1..5).to_a.each {|search_number|
			search = {}
			if cookies["search_#{search_number}_route_type".to_sym].nil?
				break
			end
			search[:search_type] = cookies["search_#{search_number}_search_type".to_sym]
			search[:route_type] = cookies["search_#{search_number}_route_type".to_sym]
			search[:route] = cookies["search_#{search_number}_route".to_sym]
			search[:stop] = cookies["search_#{search_number}_stop".to_sym]
			search[:direction] = cookies["search_#{search_number}_direction".to_sym]
			search[:destination] = cookies["search_#{search_number}_destination".to_sym]
			search[:title] = generate_title_for_cookie(search)
			search[:url] = generate_url(search)
			view_data << search
		}

		render json: view_data
	end

	def generate_title_for_cookie(cookie_values)

		# Get the route name, stop and destination name from the timetable service using the parameters stored in the cookie.
		t = TimetableService.new
		route_name = t.loadRouteDetails(cookie_values[:route])
		stop_name = t.getStopName(cookie_values[:route_type], cookie_values[:stop])
		if cookie_values[:direction].nil? == false
			direction = t.getDirectionDetails(cookie_values[:route_type], cookie_values[:route], cookie_values[:direction])
			title = "#{route_name} - #{stop_name} - #{direction[:direction_name]}"
		end
		title
	end

	def generate_title
		"#{@routeName} - #{@stop} - #{@destination}"
	end

	def generate_url(cookie_values)
		route_type = "route_type=#{cookie_values[:route_type]}"
		route = "route=#{cookie_values[:route]}"
		stop = "stop=#{cookie_values[:stop]}"
		direction = "direction=#{cookie_values[:direction]}"

		search_type = cookie_values[:search_type]

		"/#{search_type}?#{route_type}&#{route}&#{stop}&#{direction}"
	end

	def saveCookie(type)

		number = 1
		# Needed for building the link url.
		cookies["search_#{number}_search_type".to_sym] = type
		cookies["search_#{number}_route_type".to_sym] = params[:route_type]
		cookies["search_#{number}_route".to_sym] = params[:route]
		cookies["search_#{number}_stop".to_sym] = params[:stop]
		cookies["search_#{number}_direction".to_sym] = params[:direction]
		cookies["search_#{number}_destination".to_sym] = params[:destination]


		# from = 1
		# to = 2
		# move_search(from, to)
	end

	def move_search(from, to)
		searches = cookies[:searches]

		# stop = cookies["search_#{from}_stop".intern]
		# route_type = cookies["search_#{from}_route_type".intern]
		# route = cookies["search_#{from}_route".intern]
		# direction = cookies["search_#{from}_direction".intern]
		# order = cookies["search_#{from}_order".intern]

		# cookies["search_#{to}_stop".intern] = stop
		# cookies["search_#{to}_route_type".intern] = route_type
		# cookies["search_#{to}_route".intern] = route
		# cookies["search_#{to}_direction".intern] = direction
		# cookies["search_#{to}_order".intern] = order
	end

	def loadTimes
		route_type_id = params[:route_type]
		# @run_id = params[:run_id]
		start_stop_id = params[:start_stop]
		end_stop_id = params[:end_stop]
		runs = params[:runs]
		# runs is a comma separated list of run_id's
		t = TimetableService.new
		times = t.loadTimes(route_type_id, start_stop_id, end_stop_id, runs)
		render json: times
	end

# Create all the variables for the timetable page from TimetableService and the days created
# t = TimetableService
# days = [{"Day Key", [DayModel...]}]
	def setTimes(t, days)

		@routeName = t.routeName
		@destination = t.directionName
		@stop = t.stopName

		@dayViewModelMF = days["Monday to Friday"]
		@dayViewModelSAT = days["Saturday"]
		@dayViewModelSUN = days["Sunday"]
		
		@publicHolidays = t.publicHolidays
		@has_public_holiday = @publicHolidays.length > 0

	end

	def setPageClasses()
	 	case @routeTypeId 
	 	when "0"
	 		@stopClass = "stop_train"
	 		@hourClass = "hour_train"
	 		@iconImage = "metro-logo-white.png"
	 	when "1"
	 		@stopClass = "stop_tram"
	 		@hourClass = "hour_tram"
	 		@iconImage = "yarra-trams-logo-white.gif"
	 	when "2"
	 		@stopClass = "stop_bus"
	 		@hourClass = "hour_bus"
	 		@iconImage = "ventura white icon.png"
	 	when "3"
	 		@stopClass = "stop_vline"
	 		@hourClass = "hour_vline"
	 		@iconImage = "vline-logo-white-180x89.png"
	 	when "4"
	 		@stopClass = "stop_bus"
	 		@hourClass = "hour_bus"
	 		@iconImage = "ventura white icon.png"
	 	end
	end
end
