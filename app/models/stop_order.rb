class StopOrder < ApplicationRecord
  alias :eql? :==

  belongs_to :route
  belongs_to :direction
  belongs_to :stop

  def <=> (other)
    #@order <=> other.order && @route.id <=> other.route.id
	  state.to_s <=> other.state.to_s
  end
  
  def ==(other)
    other.class == self.class && other.state == state   
  end

  def state
    [route.id,direction.id,order]
  end

  def to_s
    "route: #{route.route_name}, direction: #{direction.direction_name}, stop: #{stop.stop_name}, order: #{order}"
  end

end
