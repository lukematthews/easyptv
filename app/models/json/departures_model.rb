class Departures
	attr_accessor :departures

	@public_holidays

	def initialize
		@public_holidays = {}
# Public holidays for 2018
		@public_holidays[Date.new(2018, 1, 1)] = ["New Year's Day" , "Saturday"]
		@public_holidays[Date.new(2018, 1, 26)] = ["Australia Day" , "Saturday"]
		@public_holidays[Date.new(2018, 3, 12)] = ["Labour Day" , "Saturday"]
		@public_holidays[Date.new(2018, 3, 30)] = ["Good Friday" , "Sunday"]
		@public_holidays[Date.new(2018, 4, 1)] = ["Easter Sunday" , "Saturday"]
		@public_holidays[Date.new(2018, 4, 2)] = ["Easter Monday" , "Saturday"]
		@public_holidays[Date.new(2018, 4, 25)] = ["ANZAC Day" , "Saturday"]
		@public_holidays[Date.new(2018, 11, 6)] = ["Melbourne Cup" , "Saturday"]
		@public_holidays[Date.new(2018, 12, 25)] = ["Christmas Day" , "Sunday"]
		@public_holidays[Date.new(2018, 12, 26)] = ["Boxing Day" , "Saturday"]
		
		@times = Set.new
	end

	def is_public_holiday(day)
		found = false
		keys = @public_holidays.each_key {
			|key|
			if (key.year == day.year && key.month == day.month && key.day == day.day)
				found = true
			end
		}
		found
	end

	def getHoliday(day)
		holiday = []
		keys = @public_holidays.each { |key,value|
			if (key.year == day.year && key.month == day.month && key.day == day.day)
				holiday[0] = value[0]
				holiday[1] = key
				holiday[2] = value[1]
			end
		}
		holiday
	end
end