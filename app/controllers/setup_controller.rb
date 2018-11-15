class SetupController < ApplicationController

	require 'json'

	def index
		service = SetupService.new
		@modes =  RouteType.all
		@routes = service.routes
		render
	end

	def routes
		render json: SetupService.new.routes_for_mode(params[:id])
	end

	def stops
		route_type_for_mode = RouteType.find_by(route_type: params[:id])
		route = Route.where(route_type: route_type_for_mode).find_by(
			route_id: params[:route])
		render json: route.stops.sort{|x,y| x.stop_name <=> y.stop_name}
	end

	def directions
		render json: SetupService.new.directions_for_route(params[:id])
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
