require 'swf_math.rb'

class Matrix
  # stores a 2x3 matrix as follows
  #     [ a b ]
  # A = [ c d ]
  #     [ e f ]
  # where a = scale_x, b = rotate_skew_0, c = rotate_skew_1, d = scale_y, e = translate_x, f = translate_y
  attr_accessor :scale_x, :rotate_skew_1, :translate_x, :rotate_skew_0, :scale_y, :translate_y
  
  def initialize( f )
    f.skip_to_next_byte
    b = f.total_bytes_read
    
    self.scale_x = 1
    self.rotate_skew_1 = 0
    self.translate_x = 0
    self.rotate_skew_0 = 0
    self.scale_y = 1
    self.translate_y = 0
    
    has_scale = f.next_n_bits(1)
    if(has_scale == "1")
      n_scale_bits = f.next_n_bits(5).to_i(2)
      self.scale_x = SwfMath.parse_signed_float( f.next_n_bits(n_scale_bits) )
      self.scale_y = SwfMath.parse_signed_float( f.next_n_bits(n_scale_bits) )
    end
    
    has_rotate = f.next_n_bits(1)
    if(has_rotate == "1")
      n_rotate_bits = f.next_n_bits(5).to_i(2)
      self.rotate_skew_0 = SwfMath.parse_signed_float( f.next_n_bits(n_rotate_bits) )
      self.rotate_skew_1 = SwfMath.parse_signed_float( f.next_n_bits(n_rotate_bits) )
    end
    
    n_translate_bits = f.next_n_bits(5).to_i(2)
    unless n_translate_bits == 0
      self.translate_x = SwfMath.parse_signed_int( f.next_n_bits(n_translate_bits) )
      self.translate_y = SwfMath.parse_signed_int( f.next_n_bits(n_translate_bits) )
    end
    e = f.total_bytes_read
    r = e-b
    puts r
    f.skip_to_next_byte
  end
end

class Rect
  attr_accessor :xmin, :xmax, :ymin, :ymax
  
  def initialize( f )    
    # rects are byte aligned
    f.skip_to_next_byte
      #{}"SwfMath".constantize.parse_signed_int()

    num_bits = f.next_n_bits( 5 ).to_i(2)
    self.xmin = SwfMath.parse_signed_int( f.next_n_bits( num_bits ) )
    self.xmax = SwfMath.parse_signed_int( f.next_n_bits( num_bits ) )
    self.ymin = SwfMath.parse_signed_int( f.next_n_bits( num_bits ) )
    self.ymax = SwfMath.parse_signed_int( f.next_n_bits( num_bits ) )

    # byte alignment
    f.skip_to_next_byte
  end
  
end

class RGB
  attr_accessor :r, :g, :b
  
  def initialize( f )
    f.skip_to_next_byte
    self.r = f.getc
    self.g = f.getc
    self.b = f.getc
    # puts "RGB: (#{r}, #{g}, #{b})"
    
    f.skip_to_next_byte  
  end
end