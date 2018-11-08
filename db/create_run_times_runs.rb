class CreateRunTimesRuns

	def load_all
		Routes.all.each { |route|
			route.stops.each { |stop|
				route.directions.each { |direction|
					departures = Departure.where(
						route: route, 
						stop: stop, 
						direction: direction)
					departures.each { |departure| 
						create_runs_for_departure(departure)
					}
				}
			}
		}
	end

	def create_runs_for_departure(departure)
		# Find the run day and then the run time.
		departure_time = to_local(dep.scheduled_departure_utc)
	
		runDay = RunDay.find_by(
			route: departure.route, 
			stop: departure.stop, 
			direction: departure.direction, 
			day_name: get_day_name(departure_time)
			)

		# ok, we've got the RunDay, now lets get the RunTime for the departure.
		hour = departure_time.hour
		minute = departure_time.min
		runTime = RunTime.find_by(
			runDay: runDay,
			hour: hour,
			minutes: minutes
			)

		# Get the runs from the runTime, it's a comma seperated list.
		# if the list does not contain the run_id, add it.
		# Then... save it back to the db.
		runs = runTime.runs.split(",")
		departure_run = departure.run.id
		if !runs.include?(departure_run)
			runs << departure_run
		end
		runTime.runs = runs.join(",")
		runTime.save
	end

	def to_local(departure_utc)
		utc_offset = Time.now.getlocal.utc_offset/60/60
		departure_time = DateTime.parse(departure_utc)
		departure_time + (utc_offset/24.0)
	end

	def get_day_name(departure_time)
		case departure_time.cwday
		when 6
			return RunDay::SAT
		when 7
			return RunDay::SUN
		else
			return RunDay::MF
		end
	end

end