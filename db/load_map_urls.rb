file = File.read("app/assets/reference/map_urls-2.json")
route_maps = JSON.parse(file)

routes = Route.all
routes.each {|route|
	json_route = route_maps[route.route_id.to_s]
	if !json_route.nil?	
		route.map_url = route_maps[route.route_id.to_s]["map_url"]
		route.save
	else
		puts "#{route.route_id} not found in json"
	end
}


