require 'advanced_file_reader.rb'
require 'models/shape.rb'
require 'models/sprite.rb'
require 'models/line_style.rb'
require 'models/fill_style.rb'
require 'models/generic_records.rb'
require 'swf_math.rb'


def get_tag( f )
  f.skip_to_next_byte # manual byte alignment here
  tag_1 = f.next_n_bits( 8 )
  tag_2 = f.next_n_bits( 8 )
  tag_bit_string = tag_2 + tag_1
  
  #puts "#{tag_bit_string}"
  
  tag_code = tag_bit_string.slice(0,10).to_i(2)
  tag_length = tag_bit_string.slice(10,6).to_i(2)

  if tag_length >= 63
    puts "long tag!"
    # tag_length_1 = f.getc
    # tag_length_2 = f.getc
    # tag_length_3 = f.getc
    # tag_length_4 = f.getc
    #sign = f.next_n_bits( 1 )
    # this should be signed.
    tag_length = f.get_u32 #tag_length_1 + 256*tag_length_2 + 65536*tag_length_3 + 16777216*tag_length_4
  end
  
  return [tag_code, tag_length]
end



def get_string( f )
  string = ''
  bytes_read = 0
  while true
    next_char = f.get_u8
    bytes_read += 1
    
    break if next_char == 0
    string += next_char.chr
  end
  
  return string, bytes_read
end




def get_fill_style( f ) 
  # puts "getting fill style"
  fill_style_type = f.get_u8
  
  fs = FillStyle.new
  fs.fill_style_type = fill_style_type
  
  puts "Fill Style Type: #{fill_style_type}"
  
  case fill_style_type
  when 0
    # puts "Solid Fill"
    color = RGB.new( f )
    fs.color = color
    return fs
  when '10'.to_i(16)
    puts "Linear Gradient Fill"
    raise "un-supported fill type"
  when '12'.to_i(16)
    puts "radial gradient fill"
    raise "un-supported fill type"
  when '13'.to_i(16)
    puts "focial radial gradient fill"
    raise "un-supported fill type"
  when '40'.to_i(16)
    puts "repeating bitmap fill"
    raise "un-supported fill type"
  when '41'.to_i(16)
    puts "clipped bitmap fill"
    raise "un-supported fill type"
  when '42'.to_i(16)
    puts 'non-smoothed repeating bitmap fill'
    raise "un-supported fill type"
  when '43'.to_i(16)
    puts 'non-smoothed clipped bitmap fill'
    raise "un-supported fill type"
  else
    raise "unknown fill type: #{fill_style_type}"
  end
end

def get_fill_style_array( f )
  #f.skip_to_next_byte
  puts "getting fill style array"
  fill_style_count = f.get_u8
  
  if fill_style_count == 255
    puts "extended fill style"
    #fill_style_count_extended_1 = f.getc
    #fill_style_count_extended_2 = f.getc
    fill_style_count = f.get_u16 #fill_style_count + 256*fill_style_count_extended_1
  end
  puts "Num Fill Styles: #{fill_style_count}"
  
  fill_styles = []
  fill_style_count.times do
    fill_style = get_fill_style( f )
    fill_styles.push( fill_style )
  end
  # puts "fill styles array: #{fill_styles.inspect}"
  #f.skip_to_next_byte
  return fill_styles
end

def get_line_style( f )
  # puts "getting line style"
  ls = LineStyle.new
  
  #width_1 = f.getc
  #width_2 = f.getc
  width = f.get_u16 #width_1 + 256*width_2
  
  ls.width = width
  
  color = RGB.new( f )
  ls.color = color
  
  return ls
end

def get_line_style_array( f )
  #f.skip_to_next_byte
  
  puts "getting line style array"
  line_style_count = f.get_u8
  
  if line_style_count == 255
    puts "extended line style count"
    #line_style_count_extended_1 = f.getc
    #line_style_count_extended_2 = f.getc
    line_style_count = f.get_u16#line_style_count_extended_1 + 256*line_style_count_extended_2
  end
  
  puts "Num Line Styles: #{line_style_count}"
  
  line_styles = []
  line_style_count.times do
    line_style = get_line_style( f )
    line_styles.push( line_style )
  end
  # puts "line styles array: #{line_styles.inspect}"
  #f.skip_to_next_byte
  return line_styles
end

def get_shape_record( f, num_fill_bits, num_line_bits )
  # puts "getting shape record"
  type_flag = f.next_n_bits(1)
    
  if type_flag == '0'    
    state_new_styles_flag = f.next_n_bits(1)
    # only effective in version 2 and 3
    # puts "State New Styles Flag: #{state_new_styles_flag}"
    
    state_line_style_flag = f.next_n_bits(1)
    # puts "State Line Style Flag: #{state_line_style_flag}"
    
    state_fill_style_1_flag = f.next_n_bits(1)
    # puts "State Fill Style 1 Flag: #{state_fill_style_1_flag}"
    
    state_fill_style_0_flag = f.next_n_bits(1)
    # puts "State Fill Style 0 Flag: #{state_fill_style_0_flag}"
  
    state_move_to_flag = f.next_n_bits(1)
    # puts "State Move To Flag: #{state_move_to_flag}"
    
    if (state_new_styles_flag + state_line_style_flag + state_fill_style_1_flag + state_fill_style_0_flag + state_move_to_flag) == '00000'
      # puts "End Shape Record"
      shape_record = EndShapeRecord.new
    else
      # puts "Style Change Record"
      shape_record = StyleChangeRecord.new
      if state_move_to_flag == '1'
        shape_record.state_move_to = true
        
        move_bits = f.next_n_bits(5)
        num_move_bits = move_bits.to_i(2)
      
        move_delta_x_bit_string = f.next_n_bits(num_move_bits)
        #puts "Move Delta X: #{SwfMath.parse_signed_int(move_delta_x_bit_string)}"
        shape_record.move_delta_x = SwfMath.parse_signed_int( move_delta_x_bit_string )
    
        move_delta_y_bit_string = f.next_n_bits(num_move_bits)
        #puts "Move Delta Y: #{SwfMath.parse_signed_int(move_delta_y_bit_string)}"
        shape_record.move_delta_y = SwfMath.parse_signed_int( move_delta_y_bit_string )
      end
  
      if state_fill_style_0_flag == '1'
        shape_record.state_fill_style_0 = true
        fill_style_0_bit_string = f.next_n_bits(num_fill_bits)
        puts "Fill Style 0 Bit String: #{fill_style_0_bit_string}"
        shape_record.fill_style_0 = fill_style_0_bit_string.to_i(2)
      end
  
      if state_fill_style_1_flag == '1'
        shape_record.state_fill_style_1 = true
        fill_style_1_bit_string = f.next_n_bits(num_fill_bits)
        puts "Fill Style 1 Bit String: #{fill_style_1_bit_string}"
        shape_record.fill_style_1 = fill_style_1_bit_string.to_i(2)
      end
  
      if state_line_style_flag == '1'
        #puts "STATE LINE STYLE FLAG is TRUE"
        shape_record.state_line_style = true
        line_style_bit_string = f.next_n_bits(num_line_bits)
        #puts "num line bits: #{num_line_bits}"
        #puts "Line Style Bit String: #{line_style_bit_string}"
        shape_record.line_style = line_style_bit_string.to_i(2)
        #puts "END STATE LINE STYLE SECTION"
      end
  
      if state_new_styles_flag == '1'
        fill_styles = get_fill_style_array(f)
        #puts "NEW FILL STYLES: #{fill_styles.inspect}"
        
        line_styles = get_line_style_array( f )
        #puts "NEW LINE STYLES: #{line_styles.inspect}"
        
        new_style_num_fill_bits = f.next_n_bits(4).to_i(2)
        puts "num fill bits: #{new_style_num_fill_bits}"
        new_style_num_line_bits = f.next_n_bits(4).to_i(2)
        puts "num line bits: #{new_style_num_line_bits}"

      end
    end
  else
    straight_flag = f.next_n_bits(1)
    
    if straight_flag == '1'
      # puts "Straight Edge Record"
      shape_record = StraightEdgeRecord.new
      
      num_bits_bit_string = f.next_n_bits(4)
      num_bits = num_bits_bit_string.to_i(2) + 2
      
      general_line_flag = f.next_n_bits(1)
      
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
        # puts "Delta X: #{parse_signed_int(delta_x)}"
        shape_record.delta_x = SwfMath.parse_signed_int(delta_x)
      end
      
      if general_line_flag == '1' || vert_line_flag == '1'
        delta_y = f.next_n_bits(num_bits)
        # puts "Delta Y: #{parse_signed_int(delta_y)}"
        shape_record.delta_y = SwfMath.parse_signed_int(delta_y)
      end
    else
      # puts "Curved Edge Record"
      shape_record = CurvedEdgeRecord.new
      
      num_bits_bit_string = f.next_n_bits(4)
      num_bits = num_bits_bit_string.to_i(2) + 2
      
      control_delta_x = f.next_n_bits( num_bits )
      control_delta_y = f.next_n_bits( num_bits )
      # puts "Control Delta: (#{parse_signed_int(control_delta_x)}, #{parse_signed_int(control_delta_y)})"
      shape_record.control_delta_x = SwfMath.parse_signed_int(control_delta_x)
      shape_record.control_delta_y = SwfMath.parse_signed_int(control_delta_y)
      
      anchor_delta_x = f.next_n_bits( num_bits )
      anchor_delta_y = f.next_n_bits( num_bits )
      # puts "Anchor Point: (#{parse_signed_int(anchor_delta_x)}, #{parse_signed_int(anchor_delta_y)})"
      shape_record.anchor_delta_x = SwfMath.parse_signed_int(anchor_delta_x)
      shape_record.anchor_delta_y = SwfMath.parse_signed_int(anchor_delta_y)
    end
  end
  
  return shape_record
end

def get_shape_with_style( f )
  #f.skip_to_next_byte
  
  s = Shape.new
  
  fill_styles = get_fill_style_array( f ) 
  s.fill_styles = fill_styles
   
  line_styles = get_line_style_array( f )
  s.line_styles = line_styles

  num_fill_bits = f.next_n_bits(4).to_i(2)
  puts "  NUM FILL BITS #{num_fill_bits}"
  num_line_bits = f.next_n_bits(4).to_i(2)
  puts "  NUM LINE BITS #{num_line_bits}"
  
    
  #f.skip_to_next_byte
  # bit_string = bit_string( f.getc )
  # num_fill_bits = bit_string.slice(0,4).to_i(2)
  # num_line_bits = bit_string.slice(4,4).to_i(2)
  
  # puts "num fill bits: #{num_fill_bits}"
  
  shape_records = []
  while true
    shape_record = get_shape_record( f, num_fill_bits, num_line_bits )
    shape_records.push shape_record
    break if shape_record.is_a? EndShapeRecord
  end
  # tmp = []
  # while true
  #   shape_record = get_shape_record( f, num_fill_bits, num_line_bits )
  #   
  #   if shape_record.is_a? StyleChangeRecord
  #     shape_records.push tmp if !tmp.empty?
  #     tmp = []
  #   end
  # 
  #   if shape_record.is_a? EndShapeRecord
  #     shape_records.push tmp if !tmp.empty? # add the last element
  #     shape_records = shape_records.reverse # reverse it
  #     shape_records.push shape_record       # add EndShapeRecord
  #     shape_records = shape_records.flatten # flatten
  #     break
  #   end
  #   
  #   tmp.push shape_record
  # end
  
  f.skip_to_next_byte
    
  # puts shape_records.map{|record| record.to_s}.join(" ")

  s.shape_records = shape_records
  
  return s
end
