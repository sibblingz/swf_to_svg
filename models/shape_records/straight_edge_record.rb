class StraightEdgeRecord
  attr_accessor :general_line
  attr_accessor :vert_line
  attr_accessor :delta_x
  attr_accessor :delta_y
  
  def to_svg( shape )
    if general_line
      "l#{delta_x/20.0},#{delta_y/20.0}"
    else
      if vert_line
        "v#{delta_y/20.0}"
      else
        "h#{delta_x/20.0}"
      end
    end
  end
  
  def to_txt ( shape )
    if general_line
      path = "STRAIGHT EDGE RECORD :: general line delta -> (#{delta_x/20.0},#{delta_y/20.0})"
    else
      if vert_line
        path = "STRAIGHT EDGE RECORD :: vertical line delta -> (#{delta_y/20.0})"
      else
        path = "STRAIGHT EDGE RECORD :: horizontal line delta -> (#{delta_x/20.0})"
      end
    end
    return path
  end
end