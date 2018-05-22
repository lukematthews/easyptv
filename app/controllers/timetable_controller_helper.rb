module TimetableControllerHelper

	require 'cgi'

	def read_all_cookies(as_string)
		view_data = []
		(1..5).to_a.each { |search_number|
			search_data = cookies["search_#{search_number}_data"]
			if search_data.nil? || search_data.empty?
				next
			end
			# having the search string as a hash gives us nice labelling of the
			# search in the dropdown.
			if as_string
				view_data << search_data
			else
				view_data << search_to_hash(search_data)
			end
		}
		view_data
	end


	def search_to_hash(search_data)
		# Take a comma seperated key/value pairing and create a hash.

		# search_type="timetable"|"arrivals",route_type=0|1|2|3|4,route=x,
		# stop=y,direction=z,destination="abcd",
		# title="Elsternwick to City(Flinders St) (Sandringham line)",
		search_hash = search_string_to_hash(search_data)
		search_hash["title"] = generate_title_for_cookie(search_hash)
		search_hash["url"] = generate_url(search_hash)
		search_hash
	end

	# Given a key1=value1,key2=value2,key3=value3 formatted string, convert it
	# into a hash. This is done by splitting the string into a comma seperated
	# array and then for each key/value pair, splitting it on the equals.
	# The key value pairs are then stored in the hash.
	def search_string_to_hash(search_string)
		search_array = search_string.split(",")
		# we now have an array - 
		# ["search_type=timetable", "route_type=0", etc...]
		search_hash = {}
		search_array.each() { |keyValue| 
			split_value = keyValue.split("=")
			search_hash[split_value[0]] = split_value[1]
		}
		search_hash
	end

	def generate_title_for_cookie(cookie_values)

		# Get the route name, stop and destination name 
		# from the timetable service using the parameters stored in the cookie.

		t = TimetableService.new
		route_name = t.loadRouteDetails(cookie_values["route"])
		stop_name = t.getStopName(cookie_values["route_type"], 
			cookie_values["stop"])
		if cookie_values["direction"].nil? == false
			direction = t.getDirectionDetails(
				cookie_values["route_type"], 
				cookie_values["route"], 
				cookie_values["direction"])
			direction_name = direction[:direction_name]
			title = "#{stop_name} to #{direction_name} - (#{route_name})"
		end
		title
	end

	def generate_title(stop, destination, route_name)
		"#{stop} to #{destination} (#{route_name})"
	end
	
	def generate_url(cookie_values)
		route_type = "route_type=#{cookie_values['route_type']}"
		route = "route=#{cookie_values['route']}"
		stop = "stop=#{cookie_values['stop']}"
		direction = "direction=#{cookie_values['direction']}"

		search_type = cookie_values["search_type"]

		CGI::unescape("/#{search_type}?#{route_type}&#{route}&#{stop}&#{direction}")
	end

	def cookies_contain(search_data, symbols)

		# Get the cookie as a string, either using symbol keys or string keys.
		search_string = cookie_as_string(search_data, symbols)
		# search_string = search_string_to_hash(search_data)
		search_index = -1 # this should be returned if not found.

		cookie_data = read_all_cookies(true)
		# uses string for keys.
		cookie_data.each_with_index { |data, index|
			if data.eql?(search_string)
				search_index = index
				break
			end
		}
		# If the search_index (return value) = -1, 
		# the cookies do not contain search data.
		search_index
	end

	def cookie_as_string(data, symbols)
		if symbols
			search_type = "search_type=#{data[:search_type]}"
			route_type = "route_type=#{data[:route_type]}"
			route = "route=#{data[:route]}"
			stop = "stop=#{data[:stop]}"
			direction = "direction=#{data[:direction]}"
			destination = "destination=#{data[:destination]}"
		else
			search_type = data["search_type"]
			search_type = "search_type=#{search_type}"
			
			route_type = data["route_type"]
			route_type = "route_type=#{route_type}"
			
			route = data["route"]
			route = "route=#{route}"
			
			stop = data["stop"]
			stop = "stop=#{stop}"
			
			direction = data["direction"]
			direction = "direction=#{direction}"

			destination = data["destination"]
			destination = "destination=#{destination}"
		end

		"#{search_type},#{route_type},#{route},#{stop},#{direction},#{destination}"
	end


	def saveCookie(type)

# We now have an array of all the search cookies as hashes.

# We need to convert the hashes back to strings... hmm.
		cookie_data = read_all_cookies(true)

		search_data = {}
		search_data[:search_type] = type
		search_data[:route_type] = params[:route_type]
		search_data[:route] = params[:route]
		search_data[:stop] = params[:stop]
		search_data[:direction] = params[:direction]
		search_data[:destination] = params[:destination]

		new_search_string = cookie_as_string(search_data, true)

		new_data = []
		new_data << new_search_string

# Pass true to use symbols to get the values out of the 
# search_data hash using symbols.
		cookie_index = cookies_contain(search_data, true)
		if (cookie_index == -1)
			# Not found, move all the existing cookies to the next position.

			(1..4).to_a.each() {|cookie_number|
				previous_cookie = cookie_data[cookie_number-1]
				new_data << previous_cookie
			}
		else
			# Cookie found at index "x" remove the cookie at "x" from the
			# cooke_data array.

			(0..4).to_a.each() {|cookie_number|
				if (cookie_number != cookie_index)
					new_data << cookie_data[cookie_number]
				end
			}
		end

		search_index = 1
		new_data.each { |new_cookie|
			cookie_symbol = "search_#{search_index}_data".to_sym
			cookies.permanent[cookie_symbol] = new_cookie
			search_index += 1
		}
	end
end