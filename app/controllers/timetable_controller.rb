class TimetableController < ApplicationController

	@dayViewModelMF
	@dayViewModelSAT
	@dayViewModelSUN

	@publicHolidays
	@has_public_holiday

	@routeId
	@stopId
	@directionId

	def index
		# This should really be using ids instead of names.
		# using ids means we can get the names from the api (similar to the setup page)
		@routeTypeId = params[:route_type]
		@routeId = params[:route]
		@stopId = params[:stop]
		@directionId = params[:direction]

		t = TimetableService.new
		days = t.loadDepartures(@routeTypeId, @routeId, @stopId, @directionId)

		setTimes(t, days)

		setPageClasses()


		render 
	end

	def withDepartures
		@routeTypeId = params[:route_type]
		@routeId = params[:route]
		@stopId = params[:stop]
		@directionId = params[:direction]
		@destination = params[:destination]

		t = TimetableService.new
		days = t.loadDepartures(@routeTypeId, @routeId, @stopId, @directionId)

		setTimes(t, days)

		setPageClasses()

		render
	end


# Create all the variables for the timetable page from TimetableService and the days created
	def setTimes(t, days)
		@routeName = t.routeName
		@destination = t.directionName
		@stop = t.stopName

		@dayViewModelMF = days["Monday to Friday"]
		@dayViewModelSAT = days["Saturday"]
		@dayViewModelSUN = days["Sunday"]
		
		@publicHolidays = t.publicHolidays
		@has_public_holiday = @publicHolidays.length > 0
	end

	def setPageClasses()
	 	case @routeTypeId 
	 	when "0"
	 		@stopClass = "stop_train"
	 		@hourClass = "hour_train"
	 		@iconImage = "metro-logo-white.png"
	 	when "1"
	 		@stopClass = "stop_tram"
	 		@hourClass = "hour_tram"
	 		@iconImage = "yarra-trams-logo-white.gif"
	 	when "2"
	 		@stopClass = "stop_bus"
	 		@hourClass = "hour_bus"
	 		@iconImage = "ventura white icon.png"
	 	when "3"
	 		@stopClass = "stop_vline"
	 		@hourClass = "hour_vline"
	 		@iconImage = "vline-logo-white-180x89.png"
	 	when "4"
	 		@stopClass = "stop_bus"
	 		@hourClass = "hour_bus"
	 		@iconImage = "ventura white icon.png"
	 	end
	end
end
