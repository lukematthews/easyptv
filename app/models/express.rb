class Express < ApplicationRecord
  belongs_to :start_stop
  belongs_to :end_stop
  belongs_to :route
  belongs_to :direction
end
