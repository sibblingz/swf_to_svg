class StyleChangeRecord
  attr_accessor :state_move_to
  attr_accessor :move_delta_x
  attr_accessor :move_delta_y
  
  attr_accessor :state_fill_style_0
  attr_accessor :fill_style_0
  
  attr_accessor :state_fill_style_1
  attr_accessor :fill_style_1
  
  attr_accessor :state_line_style
  attr_accessor :line_style
  
  
  def to_svg( shape )
    if state_move_to
      return_val = "<path "
      if state_fill_style_0
        fill_style = shape.fill_styles[fill_style_0 - 1]
        color = fill_style.color
        return_val += "fill='rgb(#{color[0]}, #{color[1]}, #{color[2]})' "
      end
      
      return_val += "stroke='red' stroke-width='0' d='
      M#{move_delta_x/20.0},#{move_delta_y/20.0}"
      
      if shape.shape_records.first != self
        return_val = "' />" + return_val
      end
      return return_val
    else
      raise "BAH humbug"
    end
  end
end