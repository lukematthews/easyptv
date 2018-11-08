class Pattern < ApplicationRecord
  belongs_to :stop
  belongs_to :route
  belongs_to :run
end
