class MorphFillStyleArray
  attr_accessor :count, :fill_styles
end

class MorphFillStyle
  attr_accessor :fill_style_type, :start_color, :end_color, :start_grad_matrix, :end_grad_matrix, :gradient
  attr_accessor :start_bitmap_matrix, :end_bitmap_matrix
end

class MorphGradient
  attr_accessor :num_gradients, :gradient_records
end

class MorphGradRecord
  attr_accessor :start_ratio, :start_color, :end_ratio, :end_color
end

class MorphLineStyleArray
end

class MorphLineStyle
end

class Gradient
  attr_reader :spread_mode, :interpolation_mode, :num_gradients, :gradient_records
  def initialize( f, v )
    @spread_mode = f.next_n_bits(2).to_i(2)
    
    @interpolation_mode = f.next_n_bits(2).to_i(2)
    
    @num_gradients = f.next_n_bits(4).to_i(2)
    #puts "#{spread_mode}, #{interpolation_mode}, num #{num_gradients}"
    @gradient_records = []
    
    @num_gradients.times do
      @gradient_records.push( GradRecord.new(f,v) )
    end
  end
  
  def to_xml
"<gradient num='#{num_gradients}' spread_mode='#{spread_mode_to_txt}' interpolation_mode='#{interpolation_mode_to_txt}'>
    #{ gradient_records.map{ |grad| grad.to_xml }.join("\n") }
</gradient>"
  end
  
  def spread_mode_to_txt
    case @spread_mode
    when 0
      "pad mode"
    when 1
      "reflect mode"
    when 2
      "repeat mode"
    when 3
      "reserved"
    else
      "unknown"
    end
  end
  
  def interpolation_mode_to_txt
    case @interpolation_mode
    when 0
      "normal RGB mode interpolation"
    when 1
      "linear RGB mode interpolation"
    when 2
      "reserved"
    when 3
      "reserved"
    else
      "unknown"
    end
  end
end

class GradRecord
  attr_reader :ratio, :color
  
  def initialize(f, v)
    @ratio = f.get_u8
    if( v <= 2 )
      @color = RGB.read( f )
    else
      @color = RGBA.read( f )
    end
  end
  
  def to_xml
    "<grad_record ratio='#{ratio}' #{color.to_xml_attrib} />"
  end
end

class C_XFORM
  attr_reader :red_mult_term, :green_mult_term, :blue_mult_term, 
    :red_add_term, :green_add_term, :blue_add_term

  def initialize( f )
    f.skip_to_next_byte
    
    @red_mult_term = 256
    @green_mult_term = 256
    @blue_mult_term = 256
    
    @red_add_term = 0
    @green_add_term = 0
    @blue_add_term = 0
    
    has_add_terms = f.next_n_bits(1)
    has_mult_terms = f.next_n_bits(1)
    nbits = f.next_n_bits(4).to_i(2)
    
    if(has_mult_terms=="1")
      @red_mult_term = SwfMath.parse_signed_int( f.next_n_bits(nbits) )
      @green_mult_term = SwfMath.parse_signed_int( f.next_n_bits(nbits) )
      @blue_mult_term = SwfMath.parse_signed_int( f.next_n_bits(nbits) )
    end
    
    if(has_add_terms=="1")
      @red_add_term = SwfMath.parse_signed_int( f.next_n_bits(nbits) )
      @green_add_term = SwfMath.parse_signed_int( f.next_n_bits(nbits) )
      @blue_add_term = SwfMath.parse_signed_int( f.next_n_bits(nbits) )
    end
    
    #f.skip_to_next_byte
  end
  
  def to_xml
    "<color_transform>
      <mult red='#{self.red_mult_term}' green='#{self.green_mult_term}' blue='#{self.blue_mult_term}' />
      <add red='#{self.red_add_term}' green='#{self.green_add_term}' blue='#{self.blue_add_term}' />
    </color_transform>"
  end
  
  def to_txt
    path="COLOR TRANSFORM MATRIX\n"
    path+="multiply (#{red_mult_term},#{green_mult_term},#{blue_mult_term})\n"
    path+="add (#{red_add_term},#{green_add_term},#{blue_add_term})\n"
  end
    
end

class C_XFORM_WITH_ALPHA
  attr_reader :red_mult_term, :green_mult_term, :blue_mult_term, :alpha_mult_term,
    :red_add_term, :green_add_term, :blue_add_term, :alpha_add_term

  def initialize( f )
    f.skip_to_next_byte
    
    @red_mult_term = 256
    @green_mult_term = 256
    @blue_mult_term = 256
    @alpha_mult_term = 256
    
    @red_add_term = 0
    @green_add_term = 0
    @blue_add_term = 0
    @alpha_add_term = 0
    
    has_add_terms = f.next_n_bits(1)
    has_mult_terms = f.next_n_bits(1)
    nbits = f.next_n_bits(4).to_i(2)
    
    if(has_mult_terms=="1")
      @red_mult_term = SwfMath.parse_signed_int( f.next_n_bits(nbits) )
      @green_mult_term = SwfMath.parse_signed_int( f.next_n_bits(nbits) )
      @blue_mult_term = SwfMath.parse_signed_int( f.next_n_bits(nbits) )
      @alpha_mult_term = SwfMath.parse_signed_int( f.next_n_bits(nbits) )
    end
    
    if(has_add_terms=="1")
      @red_add_term = SwfMath.parse_signed_int( f.next_n_bits(nbits) )
      @green_add_term = SwfMath.parse_signed_int( f.next_n_bits(nbits) )
      @blue_add_term = SwfMath.parse_signed_int( f.next_n_bits(nbits) )
      @alpha_add_term = SwfMath.parse_signed_int( f.next_n_bits(nbits) )
    end
    
      
    def to_xml
      "<color_transform>
        <mult red='#{self.red_mult_term}' green='#{self.green_mult_term}' blue='#{self.blue_mult_term}' alpha='#{self.alpha_mult_term}' />
        <add red='#{self.red_add_term}' green='#{self.green_add_term}' blue='#{self.blue_add_term}' alpha='#{self.alpha_add_term}' />
      </color_transform>"
    end
    
    #f.skip_to_next_byte
  end
  
  def to_txt
    path="COLOR TRANSFORM MATRIX WITH ALPHA\n"
    path+="multiply (#{red_mult_term},#{green_mult_term},#{blue_mult_term},#{alpha_mult_term})\n"
    path+="add (#{red_add_term},#{green_add_term},#{blue_add_term},#{alpha_add_term})\n"
  end
end

class Matrix
  # stores a 2x3 matrix as follows
  #     [ a b ]
  # A = [ c d ]
  #     [ e f ]
  # where a = scale_x, b = rotate_skew_0, c = rotate_skew_1, d = scale_y, e = translate_x, f = translate_y
  attr_reader :scale_x, :rotate_skew_1, :translate_x, :rotate_skew_0, :scale_y, :translate_y
  
  def initialize( f )
    f.skip_to_next_byte
    
    @scale_x = 1
    @rotate_skew_1 = 0
    @translate_x = 0
    @rotate_skew_0 = 0
    @scale_y = 1
    @translate_y = 0
    
    has_scale = f.next_n_bits(1)
    if(has_scale == "1")
      n_scale_bits = f.next_n_bits(5).to_i(2)
      @scale_x = SwfMath.parse_fixed_point( f.next_n_bits(n_scale_bits) )
      @scale_y = SwfMath.parse_fixed_point( f.next_n_bits(n_scale_bits) )
    end
    
    has_rotate = f.next_n_bits(1)
    if(has_rotate == "1")
      n_rotate_bits = f.next_n_bits(5).to_i(2)
      @rotate_skew_0 = SwfMath.parse_fixed_point( f.next_n_bits(n_rotate_bits) )
      @rotate_skew_1 = SwfMath.parse_fixed_point( f.next_n_bits(n_rotate_bits) )
    end
    
    n_translate_bits = f.next_n_bits(5).to_i(2)
    unless n_translate_bits == 0
      @translate_x = SwfMath.parse_signed_int( f.next_n_bits(n_translate_bits) )
      @translate_y = SwfMath.parse_signed_int( f.next_n_bits(n_translate_bits) )
    end

    f.skip_to_next_byte
  end
  
  def to_txt
    path="2x3 TRANSFORM MATRIX\n"
    path+="\t#{scale_x}\t#{rotate_skew_0}\n\t#{rotate_skew_1}\t#{scale_y}\n\t#{translate_x/20.0}\t#{translate_y/20.0}\n"
  end
  
  def to_xml
    "<matrix>
      <row1 col1='#{scale_x}' col2='#{rotate_skew_1}' col3='#{translate_x}'/>
      <row2 col1='#{rotate_skew_0}' col2='#{scale_y}' col3='#{translate_y}'/>
     </matrix>"
  end
end

class Rect
  attr_reader :xmin, :xmax, :ymin, :ymax
  
  def initialize( f )    
    # rects are byte aligned
    #f.skip_to_next_byte
      #{}"SwfMath".constantize.parse_signed_int()

    num_bits = f.next_n_bits( 5 ).to_i(2)
    @xmin = SwfMath.parse_signed_int( f.next_n_bits( num_bits ) )
    @xmax = SwfMath.parse_signed_int( f.next_n_bits( num_bits ) )
    @ymin = SwfMath.parse_signed_int( f.next_n_bits( num_bits ) )
    @ymax = SwfMath.parse_signed_int( f.next_n_bits( num_bits ) )

    # byte alignment
    #f.skip_to_next_byte
  end
  
  def to_xml
    "<rect xmin='#{xmin}' xmax='#{xmax}' ymin='#{ymin}' ymax='#{ymax}'/>"
  end
  
end

class RGB
  attr_accessor :r, :g, :b
  
  def self.read( f )
    rgb = self.new
    #f.skip_to_next_byte
    rgb.r = f.get_u8
    rgb.g = f.get_u8
    rgb.b = f.get_u8
    #puts "RGB: (#{r}, #{g}, #{b})"
    
    #f.skip_to_next_byte  
    return rgb
  end
  
  def to_xml
    "<RGB r='#{r}' g='#{g}' b='#{b}' a='255'/>"
  end
  
  def to_xml_attrib
    "r='#{r}' g='#{g}' b='#{b}' a='255'"
  end
end

class RGBA
  attr_accessor :r, :g, :b, :a
  
  def self.read( f )
    rgba = self.new
    #f.skip_to_next_byte
    rgba.r = f.get_u8
    rgba.g = f.get_u8
    rgba.b = f.get_u8
    rgba.a = f.get_u8
    #puts "RGB: (#{r}, #{g}, #{b})"
    
    #f.skip_to_next_byte  
    return rgba
  end
  
  def to_xml
    "<RGB r='#{r}' g='#{g}' b='#{b}' a='#{a}'/>"
  end
  
  def to_xml_attrib
    "r='#{r}' g='#{g}' b='#{b}' a='#{a}'"
  end
end

class LineStyle
  attr_accessor :width, :color
  
  def self.read( f, v )
    ls = self.new

    #width_1 = f.getc
    #width_2 = f.getc
    width = f.get_u16 #width_1 + 256*width_2

    ls.width = width
    if( v <= 2)
      color = RGB.read( f )
    else
      color = RGBA.read( f )
    end

    ls.color = color
    #f.skip_to_next_byte
    return ls
  end
  
  def to_txt
    path="LINE STYLE :: width #{width/20.0} ; color (#{color.r}, #{color.g}, #{color.b})"
  end
  
  def to_xml
    "<line_style width='#{self.width}' #{color.to_xml_attrib} />"
  end
end

class FillStyle
  attr_accessor :fill_style_type, :color, :gradient_matrix, :gradient, :bitmap_id, :bitmap_matrix
  
  def self.read( f, v )
    # puts "getting fill style"
    fill_style_type = f.get_u8

    fs = self.new
    fs.fill_style_type = fill_style_type

    #puts "Fill Style Type: #{fill_style_type}"

    case fill_style_type
    when 0
      #puts "Solid Fill"
      if( v <= 2 )
        color = RGB.read( f )
      else
        color = RGBA.read( f )
      end
      fs.color = color
    when '10'.to_i(16), '12'.to_i(16)
      fs.gradient_matrix = Matrix.new( f )
      fs.gradient = Gradient.new( f, v )
    when '13'.to_i(16)
      puts "focal radial gradient fill"
      raise "un-supported fill type"
    when '40'.to_i(16), '41'.to_i(16), '42'.to_i(16), '43'.to_i(16)
      fs.bitmap_id = f.get_u16
      fs.bitmap_matrix = Matrix.new( f )
    else
      raise "unknown fill type: #{fill_style_type}"
    end
    #f.skip_to_next_byte
    return fs
  end
  
  def to_txt
    what_fill_style
    path ="FILL STYLE :: #{fill_style_type_txt} (#{fill_style_type}) -> color (#{color.r}, #{color.g}, #{color.b})"
  end
  
  def to_xml
    return case self.fill_style_type
    when 0
      "<fill_style type='#{self.fill_style_type}' name='#{fill_style_type_txt}' #{color.to_xml_attrib} />"
    when '10'.to_i(16), '12'.to_i(16)
"<fill_style type='#{self.fill_style_type}' name='#{fill_style_type_txt}'>
  #{self.gradient_matrix.to_xml}
  #{self.gradient.to_xml}
</fill_style>"
    when '40'.to_i(16), '41'.to_i(16), '42'.to_i(16), '43'.to_i(16)
"<fill_style type='#{self.fill_style_type}' name='#{fill_style_type_txt}' bitmap_id='#{bitmap_id}'>
  #{self.bitmap_matrix.to_xml}
</fill_style>"
    else
      "<fill_style type='#{self.fill_style_type}' name='#{fill_style_type_txt}' />"
    end
  end
  
  private
    def fill_style_type_txt
      return case self.fill_style_type
      when 0
        "solid fill"
      when '10'.to_i(16)
        "linear gradient fill"
      when '12'.to_i(16)
        "radial gradient fill"
      when '13'.to_i(16)
        "focal radial gradient fill (not implemented)"
      when '40'.to_i(16)
        "repeating bitmap fill (no bitmap data)"
      when '41'.to_i(16)
        "clipped bitmap fill (no bitmap data)"
       when '42'.to_i(16)
        'non-smoothed repeating bitmap fill (no bitmap data)'
       when '43'.to_i(16)
        'non-smoothed clipped bitmap fill (no bitmap data)'
      else
        "unknown fill style"
      end
    end
end

class LineStyleArray
end

class FillStyleArray
end

class CurvedEdgeRecord
  attr_accessor :control_delta_x
  attr_accessor :control_delta_y
  attr_accessor :anchor_delta_x
  attr_accessor :anchor_delta_y
  
  def self.read( f )
    #puts "Curved Edge Record"
    shape_record = self.new

    num_bits_bit_string = f.next_n_bits(4)
    num_bits = num_bits_bit_string.to_i(2) + 2

    control_delta_x = f.next_n_bits( num_bits )
    control_delta_y = f.next_n_bits( num_bits )
    #puts "Control Delta: (#{SwfMath.parse_signed_int(control_delta_x)/20.0}, #{SwfMath.parse_signed_int(control_delta_y)/29.9})"
    shape_record.control_delta_x = SwfMath.parse_signed_int(control_delta_x)
    shape_record.control_delta_y = SwfMath.parse_signed_int(control_delta_y)

    anchor_delta_x = f.next_n_bits( num_bits )
    anchor_delta_y = f.next_n_bits( num_bits )
    #puts "Anchor Point: (#{SwfMath.parse_signed_int(anchor_delta_x)/20.0}, #{SwfMath.parse_signed_int(anchor_delta_y)/20.0})"
    shape_record.anchor_delta_x = SwfMath.parse_signed_int(anchor_delta_x)
    shape_record.anchor_delta_y = SwfMath.parse_signed_int(anchor_delta_y)
    
    return shape_record
  end
  
  def to_svg( shape )
    "q#{control_delta_x/20.0},#{control_delta_y/20.0},#{(control_delta_x+anchor_delta_x)/20.0},#{(control_delta_y+anchor_delta_y)/20.0}"
#    "l#{(control_delta_x+anchor_delta_x)/20.0},#{(control_delta_y+anchor_delta_y)/20.0}"
  end
  
  def to_txt( shape )
    path = "CURVED EDGE RECORD :: (#{control_delta_x/20.0},#{control_delta_y/20.0}) -> (#{(control_delta_x+anchor_delta_x)/20.0},#{(control_delta_y+anchor_delta_y)/20.0})"
  end
  
  def to_xml
"<curved_edge_record>
  <control_point delta_x='#{self.control_delta_x}' delta_y='#{self.control_delta_y}' />
  <anchor_point delta_x='#{self.anchor_delta_x}' delta_y='#{self.anchor_delta_y}' />
</curved_edge_record>"
  end
end

class EndShapeRecord
  
  def self.read( flags, f  )
    return self.new
  end
  
  def to_svg( shape )
    "z' />"
  end
  
  def to_txt ( shape )
    path = "END SHAPE RECORD"
  end
  
  def to_xml
"<end_shape_record></end_shape_record>"
  end
end

class StraightEdgeRecord
  attr_accessor :general_line
  attr_accessor :vert_line
  attr_accessor :delta_x
  attr_accessor :delta_y
  
  def self.read( f )
    
    shape_record = self.new
    
    num_bits_bit_string = f.next_n_bits(4)
    num_bits = num_bits_bit_string.to_i(2) + 2

    general_line_flag = f.next_n_bits(1)

  # if( general_line_flag == '1' )
  #       shape_record.general_line = true
  #       delta_x = f.next_n_bits( num_bits )
  #       delta_y = f.next_n_bits( num_bits )
  #     else
  #       vert_line_flag = f.next_n_bits(1)
  #       shape_record.vert_line = (vert_line_flag == '1')
  #       
  #       if( vert_line_flag == '1')
  #         delta_y = f.next_n_bits( num_bits )
  #       else
  #         delta_x = f.next_n_bits( num_bits )
  #       end
  #     end
    if general_line_flag == '1'
      shape_record.general_line = true
      # puts "General Line"
    end

    if general_line_flag == '0'
      vert_line_flag = f.next_n_bits(1)
      # puts (vert_line_flag == '1' ? "Vertical Line" : "Horizontal Line")
      shape_record.vert_line = (vert_line_flag == '1')
    end

    if general_line_flag == '1' || vert_line_flag == '0'
      delta_x = f.next_n_bits(num_bits)
       #puts "Delta X: #{SwfMath.parse_signed_int(delta_x)/20.0}"
       shape_record.delta_x = SwfMath.parse_signed_int(delta_x)
    end

    if general_line_flag == '1' || vert_line_flag == '1'
      delta_y = f.next_n_bits(num_bits)
      #puts "Delta Y: #{SwfMath.parse_signed_int(delta_y)/20.0}"
      shape_record.delta_y = SwfMath.parse_signed_int(delta_y)
    end
    
    return shape_record
  end
  
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
  
  def to_xml
"<straight_edge_record>
  <anchor_point delta_x='#{self.delta_x.nil? ? 0 : self.delta_x}' delta_y='#{self.delta_y.nil? ? 0 : self.delta_y}' />
</straight_edge_record>\n"
  end
end

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
  
  attr_accessor :state_new_style
  attr_accessor :line_styles
  attr_accessor :fill_styles
  attr_accessor :num_fill_bits, :num_line_bits
  
  def self.read( flags, f, v, num_fill_bits, num_line_bits )
    
    shape_record = self.new
    
    shape_record.state_new_style = (flags[0].chr == '1')
    shape_record.state_line_style = (flags[1].chr == '1')
    shape_record.state_fill_style_1 = (flags[2].chr == '1')
    shape_record.state_fill_style_0 = (flags[3].chr  == '1')
    shape_record.state_move_to = (flags[4].chr == '1')
    shape_record.num_fill_bits = num_fill_bits
    shape_record.num_line_bits = num_line_bits
    
    if shape_record.state_move_to
      move_bits = f.next_n_bits(5)
      num_move_bits = move_bits.to_i(2)

      move_delta_x_bit_string = f.next_n_bits(num_move_bits)
      #puts "Move Delta X: #{SwfMath.parse_signed_int(move_delta_x_bit_string)}"
      shape_record.move_delta_x = SwfMath.parse_signed_int( move_delta_x_bit_string )

      move_delta_y_bit_string = f.next_n_bits(num_move_bits)
      #puts "Move Delta Y: #{SwfMath.parse_signed_int(move_delta_y_bit_string)}"
      shape_record.move_delta_y = SwfMath.parse_signed_int( move_delta_y_bit_string )
    end

    if shape_record.state_fill_style_0
      #raise "shouldn't be reading state fill style 0!" unless num_fill_bits > 0
      fill_style_0_bit_string = f.next_n_bits(num_fill_bits)  # fill style of 0 means the path is not filled!
      #puts "Fill Style 0 Bit String: #{fill_style_0_bit_string}"
      shape_record.fill_style_0 = fill_style_0_bit_string.to_i(2)
    end

    if shape_record.state_fill_style_1
      fill_style_1_bit_string = f.next_n_bits(num_fill_bits)
      #puts "Fill Style 1 Bit String: #{fill_style_1_bit_string}"
      shape_record.fill_style_1 = fill_style_1_bit_string.to_i(2)
    end

    if shape_record.state_line_style
      line_style_bit_string = f.next_n_bits(num_line_bits)
      #puts "num line bits: #{num_line_bits}"
      #puts "Line Style Bit String: #{line_style_bit_string}"
      shape_record.line_style = line_style_bit_string.to_i(2)
      #puts "END STATE LINE STYLE SECTION"
    end

    if shape_record.state_new_style
      #puts "getting fill style array!"
      shape_record.fill_styles = ShapeTag.get_fill_style_array( f, v )
      #puts "NEW FILL STYLES: #{fill_styles.inspect}"
      #puts "getting line style array!"
      f.skip_to_next_byte
      shape_record.line_styles = ShapeTag.get_line_style_array( f, v )
      # the offender :( is somewhere in get_line_style_array...

      #puts "NEW LINE STYLES: #{line_styles.inspect}"

      shape_record.num_fill_bits = f.next_n_bits(4).to_i(2)

      #puts "num fill bits: #{new_style_num_fill_bits}"
      shape_record.num_line_bits = f.next_n_bits(4).to_i(2)
      #puts "num line bits: #{new_style_num_line_bits}"
    end
    
    return shape_record
  end
  
  # the important question is: when do we have a path? and when do we just have a movement?
  def to_svg( shape )
    #puts "BLAH! 1.#{state_move_to} 2.#{state_fill_style_0} 3.#{state_fill_style_1} 4.#{state_line_style}"
    # there isn't always a "path" when we move...
    if state_move_to
      return_val = "<path "
      if state_fill_style_1
        fill_style = shape.fill_styles[fill_style_1 - 1]
        color = fill_style.color
        return_val += "fill-style-1='rgb(#{color.r}, #{color.g}, #{color.b})' "
      end
      
      if state_fill_style_0
        fill_style = shape.fill_styles[fill_style_0 - 1]
        color = fill_style.color
        return_val += "fill-style-0='rgb(#{color.r}, #{color.g}, #{color.b})'"
      end
      
      return_val += " fill='none' stroke='black' stroke-width='0.5' d='M#{move_delta_x/20.0},#{move_delta_y/20.0}"
      
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
"<style_change_record state_move_to='#{state_move_to}' state_fill_style_0='#{state_fill_style_0}' state_fill_style_1='#{state_fill_style_1}' state_line_style='#{state_line_style}' state_new_style='#{state_new_style}'>
  <move_to delta_x='#{move_delta_x.nil? ? 0 : self.move_delta_x}' delta_y='#{move_delta_y.nil? ? 0 : self.move_delta_y}'/>
  <fill_style_0 index='#{fill_style_0.nil? ? "null" : (self.fill_style_0 - 1)}'/>
  <fill_style_1 index='#{fill_style_1.nil? ? "null" : (self.fill_style_1 - 1)}'/>
  <line_style index='#{line_style.nil? ? "null" : (self.line_style - 1)}'/>
  <new_style>
  #{self.line_styles_xml}
  #{self.fill_styles_xml}
  </new_style>
</style_change_record>\n"
  end
  
  
  def line_styles_xml
    if(@line_styles)
    return_val = "<line_styles>"
    return_val += line_styles.map{ |line_style| line_style.to_xml }.join('')
    return_val += "</line_styles>"
  else
    ""
  end
  end
  
  def fill_styles_xml
    if(@fill_styles)
    return_val = "<fill_styles>"
    return_val += self.fill_styles.map{ |fill_style| fill_style.to_xml }.join('')
    return_val += "</fill_styles>"
  else
    ""
  end
  end
end