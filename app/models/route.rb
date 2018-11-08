class Route < ApplicationRecord
	has_many :stops
	has_many :directions
	has_many :departures
	has_many :runs
	has_many :patterns
	
	belongs_to :route_type

	def display_name
		route_number = ""
		if !route_number.to_s.empty?
			route_number = route_number+" - "
		end
		return route_number+route_name
	end
end