class DayModel
	require 'date'
	require 'set'
	
	attr_accessor :expresses

	@key_names
	@public_holidays
	@name_key
	@name
	@times

	@runs # {"09:23" => [1234, 5678, etc...]}
	@expresses # {"09:23" => ["Cheltenham to Caulfield"]}
	@express_legend

	def initialize
		@name = ""
		@key_names = {"Monday to Friday"=>"MF", "Saturday"=>"SAT", "Sunday"=>"SUN"}
		@times = Set.new
		@runs = {}
		@expresses = {}
		@express_legend = {}
	end


	def day_name=(new_name)
 		@name_key = @key_names[new_name]
 		@name = new_name
	end

	def times=(new_times)
		@times = new_times
	end

	def runs=(runs)
		# runs = {time.to_s => [run_id, run_id]}
		@runs = runs
	end

	def runs
		@runs
	end

	def times
		@times
	end

	def name
		@name
	end

	def name_key
		@name_key
	end

	def to_s
		"name: #{@name}, name_key: #{@name_key}, times: #{@times}"
	end

	def times_for_hour(hour)
		hour_times = []
		times.each do |time|
			time_hour = time.split(":")[0].to_i
			if (time_hour == hour)
				minutes = time.split(":")[1]
				hour_times << minutes
			end
		end
		hour_times
	end	

	def last_hour(hour)
		max_hour = 0
		times.each do |time|
			time_hour = time.split(":")[0].to_i
			if time_hour > max_hour
				max_hour = time_hour
			end

		end
		hour == max_hour
	end

	# Return an array of minutes for the hour.
	def minutes_for_hour(hour)
		minutes = []
		hour_times = times_for_hour(hour)
		hour_times.each do |time|
			minutes << time			
		end
		minutes
	end

	def display_hour(hour)
		if hour > 12
			hour -= 12
		end
		hour
	end

	def initialise_express_legend(legend,route_id, direction_id)
		@express_legend = legend

		@express_key_stops = {}

		expresses_for_r_d = get_expresses_for_route_direction(route_id, direction_id)
puts "Express for route direction: #{expresses_for_r_d}"
		build_keys_stop(expresses_for_r_d)
puts "Express key stops has been initialised: #{@express_key_stops}"		
		# @express_key_stops = build_keys_stop(get_expresses_for_route_direction(route_id, direction_id))

	end

	def build_keys_stop(express_for_route_direction)
		express_for_route_direction.each { |express_legend_item|
			puts "route: #{express_legend_item['route_id']}, direction: #{express_legend_item['direction']}, express_item: #{express_legend_item}"

			express_stops_text = ""
			express_legend_item["expresses"].each { |express_item|
				express_stops_text = ""
				express_item["stops"].each { |express_stop|
					start = express_stop["start"]
					finish = express_stop["end"]
					express_stops_text << "#{start}-#{finish}, "
				}
				@express_key_stops[express_stops_text] = express_item["key"]
			}
		}

		puts "Express key stops after building: #{@express_key_stops}"

	end

	def get_expresses_for_route_direction(route_id, direction_id)
		route_expresses = @express_legend.select {
			|express_legend_item|

# puts "Selecting express legend for route/direction: #{route_id}, #{direction_id} #{express_legend_item}"
puts "legend route id: #{express_legend_item['route_id']}, day model route_id: #{route_id}"
puts "legend direction_id id: #{express_legend_item['direction']}, day model direction_id: #{direction_id}"

puts express_legend_item["route_id"].to_s == route_id.to_s &&
	express_legend_item["direction"].to_s == direction_id.to_s
			express_legend_item["route_id"].to_s == route_id.to_s &&
			express_legend_item["direction"].to_s == direction_id.to_s
		}
#puts "Express legend: #{@express_legend} Route direction expresses: #{route_expresses}"
		route_expresses
	end

	def express_for_time(hour, minute)
		time_expresses = @expresses[create_time_key(hour,minute)]
		# we now have the set of expresses. Look the up from the legend to
		# generate the value.

		# iterate over each of the legend items.
		express_stops = ""

		# puts "Getting express for time #{create_time_key(hour, minute)}, expresses: #{time_expresses}"

		time_expresses.each {|express|
			puts "#{hour}:#{minute} - #{express}"
			express.each {|express_item|
				# we now have the :start, :end stop.
				start = express_item[:start].to_s
				finish = express_item[:end].to_s
				express_stops << start + "-" + finish + ", "
			}
		} unless time_expresses.nil?

		express_display = ""
		# Iterate over all the express key stops, if the express stops include
		# 
		@express_key_stops.each { |key, value|
			# key = stops text, value = key to Display (A,C,D... etc.)
# puts "Getting express for time: legend_key: #{key}, Legend value: #{value}, stops for time: #{express_stops}"
			if (key.length > 0) && (express_stops.include? key)
# puts "Express stops #{express_stops} includes #{key}, adding: #{value}"
				express_display << value << " "
			end
		} unless @express_key_stops.nil?

		express_display
	end

	def runForTime(hour, minute)
		time_runs = @runs[create_time_key(hour, minute)]
		time_runs.to_s
	end

	def create_time_key(hour, minute)
		time = TimeModel.new
		time.hour = hour
		time.minutes = minute
		time.to_s
	end
end