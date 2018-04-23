class StopModel

    # {
    #   "stop_name": "Balaclava Station",
    #   "stop_id": 1013,
    #   "route_type": 0,
    #   "stop_latitude": -37.8694878,
    #   "stop_longitude": 144.993515
    # },
    attr_accessor :stop_name, :stop_id, :route_type, :stop_latitude, :stop_longitude, :display_name

    def display_name
        to_s
    end

    def to_s
    	@stop_name
    end
end