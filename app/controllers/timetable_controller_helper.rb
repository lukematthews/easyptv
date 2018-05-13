module TimetableControllerHelper

	def read_all_cookies()
		# The value of the cookie is a json [] containing a hash of the search parameters and the search type (arrival/withDepartures) (this comes from the params object)
		# Parse the search parameters to create a url and name of the search
		view_data = []

		# Pull the details of the recent search out of the cookie.
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
cookies["search_url_#{search_number}".to_sym] = search[:url]
# %2Ftimetable%3Froute_type%3D0%26route%3D1%26stop%3D1010%26direction%3D1
			view_data << search
		}

		view_data	
	end

	def generate_title_for_cookie(cookie_values)

		# Get the route name, stop and destination name from the timetable service using the parameters stored in the cookie.
		t = TimetableService.new
		route_name = t.loadRouteDetails(cookie_values[:route])
		stop_name = t.getStopName(cookie_values[:route_type], cookie_values[:stop])
		if cookie_values[:direction].nil? == false
			direction = t.getDirectionDetails(cookie_values[:route_type], cookie_values[:route], cookie_values[:direction])
			title = "#{stop_name} to #{direction[:direction_name]} - (#{route_name})"
		end
		title
	end

	def generate_title(stop, destination, route_name)
		"#{stop} to #{destination} (#{route_name})"
	end
	
	def generate_url(cookie_values)
		route_type = "route_type=#{cookie_values[:route_type]}"
		route = "route=#{cookie_values[:route]}"
		stop = "stop=#{cookie_values[:stop]}"
		direction = "direction=#{cookie_values[:direction]}"

		search_type = cookie_values[:search_type]

		"/#{search_type}?#{route_type}&#{route}&#{stop}&#{direction}"
	end

	def cookies_contain(search_data)

		search_string = cookie_as_string(search_data)
		search_index = -1 # this should be returned if not found.

		cookie_data = read_all_cookies # return an array of hashes.
		cookie_data.each_with_index { |data, index|
			cookie_string = cookie_as_string(data)
			if cookie_string.eql?(search_string)
				search_index = index
				break
			end
		}
		# If the search_index (return value) = -1, the cookies do not contain search data.
		search_index
	end

	def cookie_as_string(data)
		search_type = "search_type=#{data[:search_type]}"
		route_type = "route_type=#{data[:route_type]}"
		route = "route=#{data[:route]}"
		stop = "stop=#{data[:stop]}"
		direction = "direction=#{data[:direction]}"
		destination = "destination=#{data[:destination]}"
		"#{search_type},#{route_type},#{route},#{stop},#{direction},#{destination}"
	end

	def saveCookie(type)

		cookie_data = read_all_cookies()

		search_data = {}
		search_data[:search_type] = type
		search_data[:route_type] = params[:route_type]
		search_data[:route] = params[:route]
		search_data[:stop] = params[:stop]
		search_data[:direction] = params[:direction]
		search_data[:destination] = params[:destination]

p "cookie data: #{cookie_data}"
p "cookies contain? #{cookies_contain(search_data)}"
# index == 0? I wonder whatt this really means for us.
# I'm guessing index == 0 means it doesn't contain it.
# Idiot. index == 0 means the cookies contain the search at index 0

# Ok. Let's try an keep this simple.


		# Logic (v2)
		# Create an array of all the cookie strings.
		# - Does the array contain the new search? If so, remove it from the cookie array.
		# - Add the new search to the start of the cookie array
		# - Trim the array to be 5 long
		# - Remove all the existing cookies
		# - Write the new cookie array to the cookie

		# Logic...
		# cookie to be saved goes in at number 1.
		# for the cookies that are there,
		# 	-> move 4 to 5
		# 	-> move 3 to 4
		# 	-> move 2 to 3
		# 	-> move 1 to 2

		# If the current search exists, remove it from its current location. The default logic will put it in 1.
		# in order to remove the existing search, I guess

		from = 4
		to = 5
		while from > 1 
			#  If there is nothing in from, move to the next one.
			if cookies["search_#{from}_route_type".to_sym].nil?
p "no cookie for search_#{from} iterating down and skipping to the next one."
				# iterate down...
				from -= 1
				to -= 1
				next
			end

p "moving cookie_#{from} to cookie_#{to}"

			# Take the cookie value from the "from" and move it into the "to"
			cookies.permanent["search_#{to}_search_type".to_sym] = cookies["search_#{from}_search_type".to_sym]
			cookies.permanent["search_#{to}_route_type".to_sym] = cookies["search_#{from}_route_type".to_sym]
			cookies.permanent["search_#{to}_route".to_sym] = cookies["search_#{from}_route".to_sym]
			cookies.permanent["search_#{to}_stop".to_sym] = cookies["search_#{from}_stop".to_sym]
			cookies.permanent["search_#{to}_direction".to_sym] = cookies["search_#{from}_direction".to_sym]
			cookies.permanent["search_#{to}_destination".to_sym] = cookies["search_#{from}_destination".to_sym]

			# iterate down...
			from -= 1
			to -= 1
		end

		# Put the current search as the first search in the recent search list. 
		number = 1
		cookies.permanent["search_#{number}_search_type".to_sym] = type
		cookies.permanent["search_#{number}_route_type".to_sym] = params[:route_type]
		cookies.permanent["search_#{number}_route".to_sym] = params[:route]
		cookies.permanent["search_#{number}_stop".to_sym] = params[:stop]
		cookies.permanent["search_#{number}_direction".to_sym] = params[:direction]
		cookies.permanent["search_#{number}_destination".to_sym] = params[:destination]

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

end