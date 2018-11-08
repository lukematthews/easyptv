class ProgressMonitor
	
	@current
	@total
	@start

	def initialize(total)
		@total = total
		@current = 0
		@start = Time.now
	end

	def increment

		@current = @current+1
		
		now = Time.now
		elapsed = now - @start

		remaining = @total - @current
		# remaining 

		speed = @current/elapsed

		eta = eta = (now + remaining/speed).strftime("%a %T %p")

		percentage = (@current.to_f / @total.to_f) * 100.0

		printf("\r%d/%d %d%% %.2fp/s eta: %s", @current, @total, percentage, speed, eta)

        # printf("\r%d/%d %d% %dp/s eta: %s", @current, @total, percentage, speed, eta)
        if @current == @total
        	puts
        end
	end
end