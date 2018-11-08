class RouteType < ApplicationRecord
	has_many :routes
	has_many :stops
	has_many :directions
	has_many :runs
end
