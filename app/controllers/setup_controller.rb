class SetupController < ApplicationController

	require 'json'

	def index
		service = SetupService.new
		@modes =  service.modes
		@routes = service.routes
		render
	end

	# http://localhost:3000/setup/routes_for_mode?mode=4
	def routes
		@mode = params[:id]
		service = SetupService.new
		@routes = service.routes_for_mode(@mode)
		render json: @routes
	end

	def stops
		@mode = params[:id]
		@route = params[:route]
		# puts params
		# puts "mode: {@mode}, route: #{@route}"
		service = SetupService.new
		@routes = service.stops_for_route(@route, @mode)
		# puts @routes
		render json: @routes
	end

	def directions
		@route = params[:id]
		service = SetupService.new
		@directions = service.directions_for_route(@route)
		puts @directions
		render json: @directions
	end

	def bus_operators
		# WORKS!
		# fileData = '[{ "name": "Broadmeadows Bus Service", "route_numbers": ["528"]}]}'
		# render json: fileData
		
	    render :file => "#{Rails.root}/public/bus-operators.json", 
		:content_type => 'application/json',
		:layout => false
	end
end
