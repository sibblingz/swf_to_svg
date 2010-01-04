class CurvedEdgeRecord
  attr_accessor :control_delta_x
  attr_accessor :control_delta_y
  attr_accessor :anchor_delta_x
  attr_accessor :anchor_delta_y
  
  def to_svg( shape )
    "q#{control_delta_x/20.0},#{control_delta_y/20.0},#{(control_delta_x+anchor_delta_x)/20.0},#{(control_delta_y+anchor_delta_y)/20.0}"
#    "l#{(control_delta_x+anchor_delta_x)/20.0},#{(control_delta_y+anchor_delta_y)/20.0}"
  end
end