class TimeModel
	attr_accessor :hour, :minutes

	def to_s
		"#{@hour.to_s.rjust(2, '0')}:#{@minutes.to_s.rjust(2, '0')}"
	end

	def each
		yield @hour
		yield @minutes
	end

	def eql?(other)
		puts "Calling equals: #{to_s} - #{other.to_s}"
		@hour == other.hour && @minutes == other.minutes
	end
  	
  	alias_method :==, :eql?
end