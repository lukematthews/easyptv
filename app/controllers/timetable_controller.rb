class TimetableController < ApplicationController

	require 'cgi'
	require 'timetable_controller_helper'
	include TimetableControllerHelper

	mattr_accessor :express_legends
	helper_method :generate_title

	@days
	# This is a hash of RunDay::(day type) => runDay
	# the runDay then has the times.

	@publicHolidays
	@has_public_holiday

	@routeId
	@stopId
	@directionId
	@legend

	@route_maps
	@bus_icons
	@map_src
	@@express_legends

	@with_departures

	def initialize
		super
		file = File.read("app/assets/reference/map_urls-2.json")
		@route_maps = JSON.parse(file)
		file = File.read("app/assets/reference/bus_icons.json")
		@bus_icons = JSON.parse(file)
		@@express_legends = JSON.parse(File.read("app/assets/reference/expresses.json"))
	end

	def render_timetable(with_times)
		# This should really be using ids instead of names.
		# using ids means we can get the names from the api (similar to the setup page)
		@routeTypeId = params[:route_type]
		@routeId = params[:route]
		@stopId = params[:stop]
		@directionId = params[:direction]

		# Destination is the stop id of where the arrival times and trip length are calculated to.
		@destination = params[:destination]
		@end_stop_id = params[:destination]


		@route = Route.find_by(route_id: @routeId)

		@start_stop = Stop.find_by(stop_id: @stopId, route: @route)
		direction = Direction.find_by(direction_id: @directionId, route_id: @route.id)
		@end_stop = Stop.find_by(stop_id: @destination)

		get_legend

		stop_order = StopOrder.find_by(direction: direction, route: @route, stop: @start_stop)
		next_stop_order = StopOrder.find_by(direction: direction, route: @route, order: stop_order.order+1)
		previous_stop_order = StopOrder.find_by(direction: direction, route: @route, order: stop_order.order-1)

		@previous_stop = !@previous_stop_order.nil? ? @previous_stop_order.stop : nil
		@next_stop = !@next_stop_order.nil? ? @next_stop_order.stop : nil

		@routeTypeId = params[:route_type]
		@routeId = params[:route]
		@stopId = params[:stop]
		@directionId = params[:direction]

		t = TimetableServiceModel.new
		if with_times.eql? :plain
			@days = t.loadDepartures(@route, @start_stop, direction)
			@map_src = @route.map_url
			@with_departures = false
			saveCookie("timetable")
		elsif with_times.eql? :departures
			@days = t.loadDeparturesToStop(@route, @start_stop, direction, @end_stop)
			@map_src = @route_maps[@routeId]["map_url"]
			@with_departures = true
			saveCookie("arrivals")
		end
		setTimes(t, @days)

		setPageClasses()

		render 
	end


	def index
		render_timetable(:plain)
	end

	def withDepartures
		render_timetable(:departures)
	end

	def route_map
		route_id = params[:route_id]
		# Get the map image url.
		@map_src = @route_maps[route_id]["map_url"]
		render json: @map_src
	end

	def get_legend
		# get the express legend from the legend reference 
		# for the direction and route.
		@legend = @@express_legends.select {|legend_item|
			# puts "#{legend_item}"
			legend_item["route_id"].to_s == @routeId.to_s &&
			legend_item["direction"].to_s == @directionId.to_s
		}
	end


	def bootstrap
		# This should really be using ids instead of names.
		# using ids means we can get the names from the api (similar to the setup page)

		t = TimetableServiceModel.new
		days = t.loadDepartures(@routeTypeId, @routeId, @stopId, @directionId)

		setTimes(t, days)

		setPageClasses()

		# Save this as the first search and move the others down the list.
		# If this is already in the list, remove the existing one and have this at the top.
		saveCookie("timetable")
		
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
		# t = TimetableServiceExpress.new
		t = TimetableServiceModel.new
		times = t.loadTimes(route_type_id, start_stop_id, end_stop_id, runs)
		render json: times
	end

# Create all the variables for the timetable page from TimetableService and the days created
# t = TimetableService
# days = [{"Day Key", [DayModel...]}]
	def setTimes(t, days)
		@routeName = t.route_name
		@destination = t.direction_name
		@stop = t.stop_name

		@publicHolidays = t.public_holidays
		@has_public_holiday = @publicHolidays.size > 0

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
	 		# This needs to change to "operator_icon_for_route()"
			@iconImage = operator_icon_for_route(@routeId)
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

	def operator_icon_for_route(bus_route_id)
		@bus_icons[bus_route_id.to_s]["icon"]
	end
end
