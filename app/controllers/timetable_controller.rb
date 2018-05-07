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

# Cookie testing... HUZZAH!
# %7B%22stop%22%3A%221002%22%2C%22route_type%22%3A%220%22%2C%22route%22%3A%221%22%2C%22direction%22%3A%221%22%2C%22controller%22%3A%22timetable%22%2C%22action%22%3A%22index%22%7D
saveCookie()
p "search cookie: (should have parameters) #{cookies[:searches]}"
		# We need a list of 5 saved 

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

		# for the "search" key in the cookie, parse the json value into the array of recent searches.
		cookie_json = cookies["search"]
		cookie_values = JSON.parse(cookie_json)

p "COOKIE CONTENTS: #{cookie_json}"
p "PARSED CONTENTS: #{cookie_values}"

		view_data = []
		counter = 1
		cookie_values.each { | link_value |
			value = {}
			value[:search_order] = "search_#{counter}"
			value[:title] = generate_title_for_cookie(link_value) # create the search title from the cookie value
			value[:url] = generate_url(link_value) # create the url from the cookie value 
			view_data << value
			counter = counter + 1

			if counter > 5
				break
			end
		}


		# The value of the cookie is a json [] containing a hash of the search parameters and the search type (arrival/withDepartures) (this comes from the params object)
		# Parse the search parameters to create a url and name of the search

		# This method doesn't need the page (action) name, it's in params

		# new_links = []
		# new_links << {:search_order => 1, :title => generate_title, :url => generate_url}

		# counter = 2
		# cookie_values.each { | link_value |
		# 	value = {}
		# 	value[:search_order] = "search_#{counter}"
		# 	value[:title] = generate_title
		# 	value[:url] = generate_url # This needs to come from 
		# 	new_links << value
		# 	counter = counter + 1

		# 	if counter > 5
		# 		break
		# 	end
		# }

# p "Converting to json #{new_links}"
		# cookies[:search] = new_links.to_json

# p "COOKIE CONTENTS AFTER LOOP: #{cookies[:search]}"
		# {links: [
			# {
			# 	search_order: 1
			# 	title: "Ashburton train timetable",
			# 	url: "/timetable?stop=1002&route_type=0&route=1&direction=1",
			# },
			# {
			# 	search_order: 2
			# 	title: "Ashburton to Camberwell arrival times",
			# 	url: "/timetable?stop=1002&route_type=0&route=1&direction=1",
			# },
		# ]}


		# render json: cookies[:search]
		render json: view_data
	end

	def generate_title_for_cookie(cookie_values)

p "cook values for title: #{cookie_values}"

		# Get the route name, stop and destination name from the timetable service using the parameters stored in the cookie.
		t = TimetableService.new
		route_name = t.loadRouteDetails(cookie_values[:route])
		stop_name = t.getStopName(cookie_values[:route_type], cookie_values[:stop])
		destination = t.loadDirectionDetails(cookie_values[:route_type], cookie_values[:route], cookie_values[:direction])
		
		"#{@route_name} - #{@stop_name} - #{@destination}"
	end

	def generate_title
		"#{@routeName} - #{@stop} - #{@destination}"
	end

	def generate_url(cookie_values)
		""
	end

	def saveCookie()

		searches = []
		searches << params

		cookies[:searches] = searches

 # So, we want to add this search as the first one.

		stop = cookies[:search_1_stop]
		route_type = cookies[:search_1_route_type]
		route = cookies[:search_1_route]
		direction = cookies[:search_1_direction]
		order = cookies[:search_1_order]

		cookie_params = cookies[:search_1_params]

p "stop: #{stop}, route type: #{route_type}, route: #{route}, direction: #{direction}, order: #{order}, cookie_params: #{cookie_params}"
		cookie_searches = []
		cookie_searches << cookie_params

		# from = 1
		# to = 2
		# move_search(from, to)

		cookies[:search_1_route_type] = params[:route_type]
		cookies[:search_1_route] = params[:route]
		cookies[:search_1_stop] = params[:stop]
		cookies[:search_1_direction] = params[:direction]
		cookies[:search_1_order] = "search_#{1}"

		cookies[:search_1_params] = cookie_searches
# 		searches = cookies["search"]
# p "Searches from cookie(1): #{searches}"

# 		# searches = {[{
# 			# search_order: 1,
# 			# params: (json formatted parameters)
# 		# }]}
# 		if searches.nil?
# 			searches = {}
# 		else
# 			searches = JSON.parse(searches)
# 		end

# p "Searches from cookie: #{searches}"
# # Add the current search to the search array.
		

# 		counter = 2
# 		searches.each { |cookie_value|
# p "Cookie value: #{cookie_value}"
# 			cookie_value[:search_order] = "search_#{counter}"

# 			counter = counter + 1
# 		} 
# p "Json saving back to cookie: @#{searches.to_json}"
# 		cookies["search"] = searches.to_json
# p "cookie: #{cookies["search"]}"
	end

	def move_search(from, to)
		stop = cookies["search_#{from}_stop".intern]
		route_type = cookies["search_#{from}_route_type".intern]
		route = cookies["search_#{from}_route".intern]
		direction = cookies["search_#{from}_direction".intern]
		order = cookies["search_#{from}_order".intern]

		cookies["search_#{to}_stop".intern] = stop
		cookies["search_#{to}_route_type".intern] = route_type
		cookies["search_#{to}_route".intern] = route
		cookies["search_#{to}_direction".intern] = direction
		cookies["search_#{to}_order".intern] = order
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
