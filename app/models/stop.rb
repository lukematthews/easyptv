class Stop < ApplicationRecord

	has_many :departures
	has_many :patterns
	
	belongs_to :route_type
	belongs_to :route
end
