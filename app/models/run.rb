class Run < ApplicationRecord
  belongs_to :route
  belongs_to :route_type
  belongs_to :direction
end
