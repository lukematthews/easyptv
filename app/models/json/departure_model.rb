require 'time'

class Departure
	attr_accessor :stop_id, :route_id, :run_id, :direction_id, :scheduled_departure_utc
	@departureUtc

	def to_s
		"stop_id: #{@stop_id}, route_id: #{@route_id}, run_id: #{@run_id}, direction_id: #{@direction_id}, scheduled_departure_utc: #{@scheduled_departure_utc}, departureUtc: #{departureUTC()}"
	end

	def scheduled_departure_utc
		@scheduled_departure_utc
	end

	def departureUTC
		d = DateTime.parse(@scheduled_departure_utc)
		utc_offset = Time.now.localtime.utc_offset
		d + utc_offset
		d
	end
end