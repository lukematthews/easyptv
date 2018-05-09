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
		# d = DateTime.parse(@scheduled_departure_utc)
		# utc_offset = Time.now.localtime.utc_offset
		# d + utc_offset
		# d

# 		# This works if the local time of the server is AET/AEDT
# 		# utc_offset = Time.now.localtime.utc_offset

# 		# 10 for AET
		utc_offset = 10
# 		# 11 for AEDT
# 		# utc_offset = 11

		local = DateTime.parse(@scheduled_departure_utc) +	 (utc_offset/24.0)
# p local
		local
	end
end