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
  
  # the important question is: when do we have a path? and when do we just have a movement?
  def to_svg( shape )
    #puts "BLAH! 1.#{state_move_to} 2.#{state_fill_style_0} 3.#{state_fill_style_1} 4.#{state_line_style}"
    # there isn't always a "path" when we move...
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
      return ""
      # raise "BAH humbug"
    end
  end
end