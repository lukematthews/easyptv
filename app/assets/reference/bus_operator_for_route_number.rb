	require 'json'
	require_relative '../../../lib/Ptv_API'
	include PtvAPI

	# Icon map...
	icon_map = {}
	icon_map["Broadmeadows Bus Service"] = 
		"bus_logos/broadmeadows-bus-service.png"
	icon_map["Cranbourne Transit"] = "bus_logos/cranbourne-transit.png"
	icon_map["CDC Melbourne"] = "bus_logos/cdc-melbourne.png"
	icon_map["Dyson's Bus Services"] = "bus_logos/dyson-logo-dark_2x.png" 
	icon_map["East West Bus Company"] = "bus_logos/dyson-logo-dark_2x.png"
	icon_map["Kastoria Bus Lines"] = "bus_logos/kastoria-buslines.png"
	icon_map["Martyrs Bus Service"] = "bus_logos/martyrs bus service.jpg"
	icon_map["McKenzie's Tourist Services"] = 
		"bus_logos/McKenzie's Tourist Services Pty Ltd.png"
	icon_map["Moreland Buslines"] = "bus_logos/moreland_bus_group.png"
	icon_map["Panorama Coaches"] = "bus_logos/panorama-logo.png"
	icon_map["Reservoir Bus Company"] = "bus_logos/dyson-logo-dark_2x.png"
	icon_map["Ryan Brothers Bus Service"] = 
		"bus_logos/ryan-brothers-bus-service.png"
	icon_map["Sita Buslines"] = "bus_logos/sita-buslines.png"
	icon_map["Sunbury Bus Service"] = "bus_logos/sunbury-bus-service.gif" 
	icon_map["Transdev Melbourne"] = "bus_logos/transdev-logo-tag.png"
	icon_map["Tullamarine Bus Lines"] = 
		"bus_logos/Tullamarine_Logo_Banner3.png"
	icon_map["Ventura Bus Lines"] = "bus_logos/ventura white icon.png"


	# let's get all the bus operators
	route_operators = {}
	file = File.read("bus-operators.json")
	bus_operator_json = JSON.parse(file)
	bus_operator_json.each do |operator|
		# Each operator has a name and an array of route numbers,
		# each route number then becomes a key to get the operator name
		operator_name = operator["name"]
		operator_routes = operator["route_numbers"].each do |route_number|
			route_operators[route_number.to_s] = {
				:operator => operator_name,
				:icon => icon_map[operator_name]
			}
		end
	end

	p route_operators

	# Get all the bus routes.
	map = {}	
	data = run("/v3/routes?route_types=2&")
	routes = data["routes"]
	# build a map of route number -> route_id
	routes.each do |route|
		route_id = route["route_id"]
		route_number = route["route_number"]
		route_operator = route_operators[route_number.to_s]
# p "route_id: #{route_id}, route_number: #{route_number}, route_operator: #{route_operator}"

		if route_operator.nil?
			route_operator = {
				:operator => "PTV",
				:icon => "bus_logos/iconBus.png"}
		end
		map[route["route_id"]] = route_operator
	end

	p map

	File.open("bus_icons.json","w") do |f|
		f.write(JSON.pretty_generate(map))
	end