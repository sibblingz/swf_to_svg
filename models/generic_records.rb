require 'swf_math.rb'

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

    #f.skip_to_next_byte
  end
  
  def to_txt
    path="2x3 TRANSFORM MATRIX\n"
    path+="\t#{scale_x}\t#{rotate_skew_0}\n\t#{rotate_skew_1}\t#{scale_y}\n\t#{translate_x/20.0}\t#{translate_y/20.0}\n"
  end
  
  def to_xml
    "<matrix>
      <row1 col1='#{scale_x}' col2='#{rotate_skew_0}'/>
      <row2 col1='#{rotate_skew_1}' col2='#{scale_y}'/>
      <row3 col1='#{translate_x}' col2='#{translate_y}'/>
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
  attr_reader :r, :g, :b
  
  def initialize( f )
    #f.skip_to_next_byte
    @r = f.get_u8
    @g = f.get_u8
    @b = f.get_u8
    #puts "RGB: (#{r}, #{g}, #{b})"
    
    #f.skip_to_next_byte  
  end
  
  def to_xml
    "<RGB r='#{r}' g='#{g}' b='#{b}'/>"
  end
  
  def to_xml_attrib
    "r='#{r}' g='#{g}' b='#{b}'"
  end
end

class NilClass
  def to_xml
    ""
  end
end