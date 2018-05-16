class TimetableController < ApplicationController

	require 'cgi'
	require 'timetable_controller_helper'
	include TimetableControllerHelper

	helper_method :generate_title

	@dayViewModelMF
	@dayViewModelSAT
	@dayViewModelSUN

	@publicHolidays
	@has_public_holiday

	@routeId
	@stopId
	@directionId

	@hello

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

		# Save this as the first search and move the others down the list.
		# If this is already in the list, remove the existing one and have this at the top.
		saveCookie("timetable")

		render 
	end

	def withDepartures
		@routeTypeId = params[:route_type]
		@routeId = params[:route]
		@stopId = params[:stop]
		@directionId = params[:direction]
		# Destination is the stop id of where the arrival times and trip length are calculated to.
		@destination = params[:destination]
		@end_stop_id = params[:destination]
		t = TimetableService.new
		
		@end_stop = t.getStopName(@routeTypeId, @destination)

		days = t.loadDeparturesToStop(@routeTypeId, @routeId, @stopId, @directionId, @end_stop)

		setTimes(t, days)

		setPageClasses()

		render
	end

	def recentSearches
		view_data = read_all_cookies(false)
		render json: view_data
	end

	def loadTimes
		route_type_id = params[:route_type]
		# @run_id = params[:run_id]
		start_stop_id = params[:start_stop]
		end_stop_id = params[:end_stop]
		runs = params[:runs]
		# runs is a comma separated list of run_id's
		t = TimetableService.new
		times = t.loadTimes(route_type_id, start_stop_id, end_stop_id, runs)
		render json: times
	end

# Create all the variables for the timetable page from TimetableService and the days created
# t = TimetableService
# days = [{"Day Key", [DayModel...]}]
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
		mode = "bus"
	 	case @routeTypeId 
	 	when "0"
	 		mode = "train"
	 		@iconImage = "metro-logo-white.png"
	 	when "1"
	 		mode = "tram"
	 		@iconImage = "yarra-trams-logo-white.gif"
	 	when "2"
	 		@iconImage = "ventura white icon.png"
	 	when "3"
	 		mode = "vline"
	 		@iconImage = "vline-logo-white-180x89.png"
	 	when "4"
	 		# night bus
	 		@iconImage = "ventura white icon.png"
	 	end

	 	@stopClass = "stop_#{mode}"
	 	@hourClass = "hour_#{mode}"
	end
end
