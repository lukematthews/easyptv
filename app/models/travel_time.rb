class TravelTime

	require 'set'

	attr_accessor :stops, :departure, :duration, :min_duration, :max_duration, :arrival, :earliest_arrival, :latest_arrival

	def initialize
		@stops = Set.new
	end
end