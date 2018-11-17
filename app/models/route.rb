class Route < ApplicationRecord
	has_many :stops
	has_many :directions
	has_many :departures
	has_many :runs
	has_many :patterns
	
	belongs_to :route_type

	def display_name
		
		# Add the word " Line" to a train line.
		if route_type.route_type ==  0
			return "#{route_name} Line"
		end

		route_number = ""
		if !route_number.to_s.empty?
			route_number = route_number+" - "
		end
		return route_number+route_name
	end
end