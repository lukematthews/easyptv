class Direction < ApplicationRecord
	has_many :departures
	has_many :runs
	
	belongs_to :route
	belongs_to :route_type
end
