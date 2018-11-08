class RunDay < ApplicationRecord
	belongs_to :route
	belongs_to :stop
	belongs_to :direction

	has_many :run_times

	MF = "Monday to Friday"
	SAT = "Saturday"
	SUN = "Sunday"

	def last_hour(hour)
		max_hour = 0
		run_times.each do |time|
			time_hour = time.hour
			max_hour = time_hour > max_hour ? time_hour : max_hour
			# time_hour = time.split(":")[0].to_i
			# if time_hour > max_hour
			# 	max_hour = time_hour
			# end
		end
		hour == max_hour
	end

	def times_for_hour(hour)
		hour_times = []
		run_times.each {|time|
			if time.hour == hour
				hour_times << time.minutes
			end
		}
		hour_times
	end

	def minutes_for_hour(hour)
		minutes = []
		hour_times = times_for_hour(hour)
		hour_times.each { |time|
			minutes << "%02d" % time
		}
		minutes.sort
	end

	def display_hour(hour)
		if hour > 12
			hour -= 12
		end
		if hour == 0
			hour = 12
		end
		hour
	end

	def runForTime(hour, minute)
		if @runs.nil?
			load_runs
		end
		run_times.find { |run_time| run_time.hour == hour && run_time.minutes == minute }
		
#		time_runs = @runs[create_time_key(hour, minute)]
#		time_runs.to_s
	end

	# Retrieve all the runs for this day.
	def load_runs()

		departures = Departure.where(route: route, direction: direction, stop: stop)

		# create a hash where the key is the run_time and the value is a sorted_set of run ids
		@runs = {}
		departures.each { |departure| 
			#get the hour and minutes of the departure.
			local = localtime_from_departure(departure.scheduled_departure_utc)

			# find the run_time for the departure.
			run_time = run_times.find { |run_time| run_time.hour == local.hour && run_time.minutes == local.min}
		}
	end

	def localtime_from_departure(departure_date)
		# Given a date/time string in UTC, convert it to local time.
		# oh, and this must only be run in rails. 'in_time_zone' does not exist in normal ruby
		d = DateTime.parse(departure_date)
		d = d.in_time_zone('Australia/Melbourne')
		d.to_time
	end
end

