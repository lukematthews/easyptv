class Departure < ApplicationRecord
  belongs_to :stop
  belongs_to :route
  belongs_to :run
  belongs_to :direction

  def to_s
  	"Route: #{route.route_name} Stop: #{stop.stop_name} Direction: #{direction.direction_name} Time: #{scheduled_departure_utc}"
  end
end
