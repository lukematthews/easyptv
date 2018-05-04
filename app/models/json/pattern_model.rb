class PatternModel
	attr_accessor :departure, :earliest_arrival, :latest_arrival, :min_duration, :max_duration 
# These class variables are for the case where either the arrival time or the duration is the same.
	attr_accessor :arrival, :duration 
end