class Express
	attr_accessor :expresses, :stops_for_route, :stops
	@each_express


	def initialize
		@expresses = []
		@stops_for_route = []
		@stops = []
		@each_express = []
	end

	def find_and_compress
		create_each_express
		did_compression = true
		while did_compression do
			did_compression = find_expresses
		end
	end

	def create_each_express
		skipped = @stops_for_route - @stops
		# p "skipped: #{skipped}"

		# Create a list of every express. This does not join the expresses together.
		each_express = []
		skipped_route_stops = []
		counter = 0
		skipped.each {|skipped_stop|
			counter += 1
			route_index = @stops_for_route.index(skipped_stop)

			start = route_index-1
			finish = route_index+1
			start_name = @stops_for_route[start]
			finish_name = @stops_for_route[finish]
			if !finish_name.nil?
				express_text = "#{start_name}to #{finish_name}"
				@each_express << {:start => start, :end => finish, :text=>express_text}
			end
			skipped_route_stops << route_index
			# express << [route_index-1, route_index+1]
		}	
	end

	def find_expresses

		did_compression = false

		# p "skipped stops on route: #{skipped_route_stops}"
		# p "each express: #{each_express}"

		# ok. Now join the expresses together where we can to make longer single expresses.
		joined_express = []
		counter = 0
		@each_express.each {|express|

			# puts "#{counter}: (the current express being looked at) #{express}"
			
			# if :end == next express... :start+1, join together
			current_start = express[:start]
			current_end = express[:end]

			next_start = -1
			next_end = -1
			# are we at the last express? if so, don't try and get the next start/end,
			# we're already at the last express.
			if !@each_express[counter+1].nil?
				next_start = @each_express[counter+1][:start]
				next_end = @each_express[counter+1][:end]
			end

			if current_end > next_start && next_start > -1
				# puts "#{counter}: (current_end is greater than the next_start) Join #{express} to #{@each_express[counter+1]}"
				# current_start to next_end

				# express_text = "#{@stops_for_route[current_start]}to #{@stops_for_route[next_end]}"

				compressed = {
					:start=> current_start, 
					:end=> next_end, 
					# :text=>express_text
				}

				@each_express[counter] = compressed
				joined_express << compressed

				# puts "#{counter}: delete #{counter+1} from each_express. #{@each_express}"

				@each_express.delete_at(counter+1)

				did_compression = true

				# puts "#{counter}: each express now looks like: #{@each_express}"
			elsif current_end < next_start && next_start > -1
				# puts "#{counter}: #{current_end} < #{next_start} (#{current_start},#{current_end} - #{next_start},#{next_end}) ... adding #{express} to joined_express"

				previous_express = joined_express.last
				if !previous_express.nil? && previous_express[:end] != current_end
					# puts "#{counter}: the end of the previous_express does not equal the current_end"
					joined_express << express
				end
			else
				# puts "#{counter}: nothing done, add it."
				joined_express << express
			end
			# p "current_end: #{current_end}, next_start: #{next_start}"
			counter += 1
		}

		# p "joined_express: #{joined_express}"
		# "skipped route index: [2, 6, 7]"
		# Find the continuous runs of stops. The difference between 2 and 6 is greater than 1. The difference between 6 and 7 is 1 - they are continuous.

		# "express runs: [[1,3],[5,7]]"
		# expresses: 
		# 	"Kananook to Carrum" (1,3)",
		# 	"Chelsea to Mordialloc (5,7)"

		@expresses = @each_express

		did_compression
	end
end