class MapsController < ApplicationController
	require 'Ptv_API'
	include PtvAPI

	require 'json'
	require 'open-uri'

	require_relative '../models/json/route_type_model'
	require_relative '../models/json/route_model'


	def index
		modes = []
		data = run("/v3/route_types?")
		data["route_types"].each do |route_type|
			r = RouteType.new
			r.route_type_name = route_type["route_type_name"]
			r.route_type = route_type["route_type"]
			modes << r
		end
		modes

		route_type_names = {
			0 => "metropolitan-trains",
			1 => "metropolitan-trams",
			2 => "metropolitan-buses",
			3 => "vline",
			4 => "night-bus",
		}

		routes = []
		data = run("/v3/routes?")
		data["routes"].each do |route|
			r = Route.new
			r.route_type = route["route_type"]
			r.route_id = route["route_id"]
			r.route_name = route["route_name"]
			r.route_number = route["route_number"]
			r.display_name = r.to_s
			routes << r
		end
		routes = routes.sort {|x,y| x.display_name <=> y.display_name }

		# Now for the fun part. For each route, generate the url.
		# https://www.ptv.vic.gov.au/getting-around/maps/(metropolitan-buses)(route_type)/view/(3438)(route_id)/

		# view_data = []

		view_data = {}

		routes.each {|route|
			route_type_name = route_type_names[route.route_type]
			if (route_type_name.eql?("vline"))
				url = nil
				map_url = "PTV-Regional-Network-Map.png"
			elsif (route_type_name.eql?("night-bus"))
				# No easy way to get the map. Maybe hard code it? BOO.
				url = nil
				map_url = nil
			else				
				url = "https://www.ptv.vic.gov.au/getting-around/maps/#{route_type_name}/view/#{route.route_id}/"

				# We have the route url, get the page from it. (open-uri)
				# This will give us the <img id="route-map" src="foo"> tag
				# download = open(url)
				page = Nokogiri::HTML(open(url))
				image = page.css('#route-map')
				if image[0].nil? == false
					map_url = image[0]["src"]
p "MAP SRC: #{map_url}"
				end
			end
			view_data[route.route_id] = {:route_type_name => route_type_name, :url => url, :route_id => route.route_id, :map_url => map_url}
		}
		render json: view_data
	end

	def map_for_route
		# Get the map url for the given route id

	end

	def load_route
		routes = []
		data = run("/v3/routes?")
		data["routes"].each do |route|
			r = Route.new
			r.route_type = route["route_type"]
			r.route_id = route["route_id"]
			r.route_name = route["route_name"]
			r.route_number = route["route_number"]
			r.display_name = r.to_s
			routes << r
		end
		routes = routes.sort {|x,y| x.display_name <=> y.display_name }
		
	end
end
