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
		@routeName = t.routeName
		@destination = t.directionName
		@stop = t.stopName

		@dayViewModelMF = days["Monday to Friday"]
		@dayViewModelSAT = days["Saturday"]
		@dayViewModelSUN = days["Sunday"]
		
		@publicHolidays = t.publicHolidays
		@has_public_holiday = @publicHolidays.length > 0

	 	case @routeTypeId 
	 	when "0"
	 		@stopClass = "stop_train"
	 		@hourClass = "hour_train"
	 		@iconImage = "metro-logo-white.png"
	 		# @routeName = "#{@routeName} Line"
	 	when "1"
	 		@stopClass = "stop_tram"
	 		@hourClass = "hour_tram"
	 		@iconImage = "yarra-trams-logo-white.gif"
	 	when "2"
	 		@stopClass = "stop_bus"
	 		@hourClass = "hour_bus"
	 		@iconImage = "ventura white icon.png"
	 	else
	 		@stopClass = "stop"
	 	end

		render 
	end
end
