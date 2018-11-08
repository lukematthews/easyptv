class RunTime < ApplicationRecord
	belongs_to :run_day
	has_many :run_times

	def to_s
		"#{self.hour.to_s.rjust(2, '0')}:#{self.minutes.to_s.rjust(2, '0')}"
	end
end
