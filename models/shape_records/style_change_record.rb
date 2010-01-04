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
  
  
  def to_s
    if state_move_to
      "
      M#{move_delta_x/20.0},#{move_delta_y/20.0}"
    else
      raise "BAH humbug"
    end
  end
end