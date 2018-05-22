class DayModel
	require 'date'
	
	@key_names
	@public_holidays
	@name_key
	@name
	@times

	@runs

	def initialize
		@name = ""
		@key_names = {"Monday to Friday"=>"MF", "Saturday"=>"SAT", "Sunday"=>"SUN"}
		@times = Set.new
		@runs = {}
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

	def runForTime(hour, minute)
		# key = "#{hour}:#{minute}"
		time = TimeModel.new
		time.hour = hour
		time.minutes = minute
		key = time.to_s
		
		time_runs = @runs[key]
		time_runs.to_s
	end
end