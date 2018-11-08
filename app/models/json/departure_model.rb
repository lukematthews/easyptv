require 'time'

class Departure
	attr_accessor :stop_id, :route_id, :run_id, :direction_id, :scheduled_departure_utc
	@departureUtc

	def to_s
		"stop_id: #{@stop_id}, route_id: #{@route_id}, run_id: #{@run_id}, direction_id: #{@direction_id}, scheduled_departure_utc: #{@scheduled_departure_utc}, departureUtc: #{departureUTC()}"
	end

	def departureUTC
# 		# 10 for AET
		# utc_offset = 10
# 		# 11 for AEDT
# 		# utc_offset = 11

		utc_offset = Time.now.getlocal.utc_offset/60/60
		DateTime.parse(@scheduled_departure_utc) +	 (utc_offset/24.0)
	end
end