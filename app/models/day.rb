class Day < ApplicationRecord
  belongs_to :route
  belongs_to :stop
  belongs_to :direction
end
