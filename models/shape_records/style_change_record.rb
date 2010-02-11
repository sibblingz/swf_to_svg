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
        return_val += "fill='rgb(#{color.r}, #{color.g}, #{color.b})' "
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
  
  def to_txt( shape )
    
    if state_move_to
      #puts "#{move_delta_x/20.0}, #{move_delta_y/20.0}"
      path = "STYLE CHANGE RECORD :: move to (#{move_delta_x/20.0}, #{move_delta_y/20.0})"
      puts "#{path}"
      if state_fill_style_0
        puts "#{shape}"
        fill_style = shape.fill_styles[fill_style_0 - 1]
        color = fill_style.color
        path += " ; fill0[#{fill_style_0-1}] (#{color.r}, #{color.g}, #{color.b})"
      end
      
      if state_fill_style_1
        path += " ; fill1[#{fill_style_1-1}]"
      end
      
      if state_line_style
        path += " ; line[#{line_style-1}]"
      end
 
    else
      path = "STYLE CHANGE RECORD :: unknown style change"
    end
    
    return path
  end
  
  def to_xml
"<style_change_record state_move_to='#{!state_move_to.nil?}' state_fill_style_0='#{!state_fill_style_0.nil?}' state_fill_style_1='#{!state_fill_style_1.nil?}' state_line_style='#{!state_line_style.nil?}'>
  <move_to delta_x='#{move_delta_x.nil? ? 0 : self.move_delta_x}' delta_y='#{move_delta_y.nil? ? 0 : self.move_delta_y}'/>
  <fill_style_0 index='#{fill_style_0.nil? ? "null" : (self.fill_style_0 - 1)}'/>
  <fill_style_1 index='#{fill_style_1.nil? ? "null" : (self.fill_style_1 - 1)}'/>
  <line_style index='#{line_style.nil? ? "null" : (self.line_style - 1)}'/>
</style_change_record>\n"
  end
  
end