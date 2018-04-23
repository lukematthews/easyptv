class DirectionModel

    # {
    #   "direction_id": 1,
    #   "direction_name": "City (Flinders Street)",
    #   "route_id": 12,
    #   "route_type": 0
    # },

    attr_accessor :direction_id, :direction_name, :route_id, :route_type, :display_name

    def display_name
        to_s
    end

    def to_s
    	@direction_name
    end
end