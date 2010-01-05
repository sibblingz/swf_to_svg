Dir.glob('models/shape_records/*') do |file|
  require file
end

require 'advanced_file_reader.rb'
require 'models/shape.rb'
require 'models/sprite.rb'
require 'models/line_style.rb'
require 'models/fill_style.rb'

DICTIONARY = {}



def int_from_twips( twips )
  remainder = twips.slice(1,twips.size)
  negative = (twips[0] == '1'[0])
  if negative
    temp_val = remainder.gsub('0','t').gsub('1','0').gsub('t','1').to_i(2)
    -1*temp_val - 1
  else
    remainder.to_i(2)
  end
end

def get_string( f )
  string = ''
  bytes_read = 0
  while true
    next_char = f.getc
    bytes_read += 1
    
    break if next_char == 0
    string += next_char.chr
  end
  
  return string, bytes_read
end

def get_rect( f )
  num_bits = f.next_n_bits( 5 ).to_i(2)
  xmin = int_from_twips( f.next_n_bits( num_bits ) )
  xmax = int_from_twips( f.next_n_bits( num_bits ) )
  ymin = int_from_twips( f.next_n_bits( num_bits ) )
  ymax = int_from_twips( f.next_n_bits( num_bits ) )
  return [xmin, xmax, ymin, ymax]
end

def get_rgb( f )
  r = f.getc
  g = f.getc
  b = f.getc
  # puts "RGB: (#{r}, #{g}, #{b})"
  return [r,g,b]
end

def get_fill_style( f )
  # puts "getting fill style"
  fill_style_type = f.getc
  
  fs = FillStyle.new
  fs.fill_style_type = fill_style_type
  
  case fill_style_type
  when 0
    # puts "Solid Fill"
    color = get_rgb( f )
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
  # puts "getting fill style array"
  fill_style_count = f.getc
  
  if fill_style_count == 255
    fill_style_count_extended_1 = f.getc
    fill_style_count_extended_2 = f.getc
    fill_style_count = fill_style_count_extended_1 + 256*fill_style_count_extended_2
  end
  # puts "Num Fill Styles: #{fill_style_count}"
  
  fill_styles = []
  fill_style_count.times do
    fill_style = get_fill_style( f )
    fill_styles.push( fill_style )
  end
  # puts "fill styles array: #{fill_styles.inspect}"
  return fill_styles
end

def get_line_style( f )
  # puts "getting line style"
  
  ls = LineStyle.new
  
  width_1 = f.getc
  width_2 = f.getc
  width = width_1 + 256*width_2
  
  ls.width = width
  
  color = get_rgb( f )
  ls.color = color
  
  return ls
end

def get_line_style_array( f )
  # puts "getting line style array"
  line_style_count = f.getc
  
  if line_style_count == 255
    line_style_count_extended_1 = f.getc
    line_style_count_extended_2 = f.getc
    line_style_count = line_style_count_extended_1 + 256*line_style_count_extended_2
  end
  
  # puts "Num Line Styles: #{line_style_count}"
  
  line_styles = []
  line_style_count.times do
    line_style = get_line_style( f )
    line_styles.push( line_style )
  end
  # puts "line styles array: #{line_styles.inspect}"
  return line_styles
end

def get_shape_record( f, num_fill_bits, num_line_bits )
  # puts "getting shape record"
  type_flag = f.next_n_bits(1)
    
  if type_flag == '0'    
    state_new_styles_flag = f.next_n_bits(1)
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
        # puts "Move Delta X: #{int_from_twips(move_delta_x_bit_string)}"
        shape_record.move_delta_x = int_from_twips( move_delta_x_bit_string )
    
        move_delta_y_bit_string = f.next_n_bits(num_move_bits)
        # puts "Move Delta Y: #{int_from_twips(move_delta_y_bit_string)}"
        shape_record.move_delta_y = int_from_twips( move_delta_y_bit_string )
      end
  
      if state_fill_style_0_flag == '1'
        shape_record.state_fill_style_0 = true
        fill_style_0_bit_string = f.next_n_bits(num_fill_bits)
        # puts "Fill Style 0 Bit String: #{fill_style_0_bit_string}"
        shape_record.fill_style_0 = fill_style_0_bit_string.to_i(2)
      end
  
      if state_fill_style_1_flag == '1'
        shape_record.state_fill_style_1 = true
        fill_style_1_bit_string = f.next_n_bits(num_fill_bits)
        # puts "Fill Style 1 Bit String: #{fill_style_1_bit_string}"
        shape_record.fill_style_1 = fill_style_1_bit_string.to_i(2)
      end
  
      if state_line_style_flag == '1'
        shape_record.state_line_style = true
        line_style_bit_string = f.next_n_bits(num_line_bits)
        # puts "Line Style Bit String: #{line_style_bit_string}"
        shape_record.line_style = line_style_bit_string.to_i(2)
      end
  
      if state_new_styles_flag == '1'
        fill_styles = get_fill_style_array(f)
        # puts "NEW FILL STYLES: #{fill_styles.inspect}"
        
        line_styles = get_line_style_array( f )
        # puts "NEW LINE STYLES: #{line_styles.inspect}"
        
        num_fill_bits = f.next_n_bits(4).to_i(2)
        # puts "num fill bits: #{num_fill_bits}"
        num_line_bits = f.next_n_bits(4).to_i(2)
        # puts "num line bits: #{num_line_bits}"
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
        # puts "Delta X: #{int_from_twips(delta_x)}"
        shape_record.delta_x = int_from_twips(delta_x)
      end
      
      if general_line_flag == '1' || vert_line_flag == '1'
        delta_y = f.next_n_bits(num_bits)
        # puts "Delta Y: #{int_from_twips(delta_y)}"
        shape_record.delta_y = int_from_twips(delta_y)
      end
    else
      # puts "Curved Edge Record"
      shape_record = CurvedEdgeRecord.new
      
      num_bits_bit_string = f.next_n_bits(4)
      num_bits = num_bits_bit_string.to_i(2) + 2
      
      control_delta_x = f.next_n_bits( num_bits )
      control_delta_y = f.next_n_bits( num_bits )
      # puts "Control Delta: (#{int_from_twips(control_delta_x)}, #{int_from_twips(control_delta_y)})"
      shape_record.control_delta_x = int_from_twips(control_delta_x)
      shape_record.control_delta_y = int_from_twips(control_delta_y)
      
      anchor_delta_x = f.next_n_bits( num_bits )
      anchor_delta_y = f.next_n_bits( num_bits )
      # puts "Anchor Point: (#{int_from_twips(anchor_delta_x)}, #{int_from_twips(anchor_delta_y)})"
      shape_record.anchor_delta_x = int_from_twips(anchor_delta_x)
      shape_record.anchor_delta_y = int_from_twips(anchor_delta_y)
    end
  end
  
  return shape_record
end

def get_shape_with_style( f )
  s = Shape.new
  
  fill_styles = get_fill_style_array( f ) 
  s.fill_styles = fill_styles
   
  line_styles = get_line_style_array( f )
  s.line_styles = line_styles

  num_fill_bits = f.next_n_bits(4).to_i(2)
  num_line_bits = f.next_n_bits(4).to_i(2)
  
  # bit_string = bit_string( f.getc )
  # num_fill_bits = bit_string.slice(0,4).to_i(2)
  # num_line_bits = bit_string.slice(4,4).to_i(2)
  
  # puts "num fill bits: #{num_fill_bits}"
  # puts "num line_bits: #{num_line_bits}"
  
  shape_records = []
  while true
    shape_record = get_shape_record( f, num_fill_bits, num_line_bits )
    shape_records.push shape_record
    break if shape_record.is_a? EndShapeRecord
  end
  
  f.skip_to_next_byte
    
  # puts shape_records.map{|record| record.to_s}.join(" ")

  s.shape_records = shape_records
  
  return s
end

def symbol_class( tag_length, f )
  puts "Symbol Class Tag"
  num_symbols = f.getc + 256*f.getc
  # puts "Num Symbols: #{num_symbols}"
  
  tag_1 = f.getc + 256*f.getc
  # puts "Tag1: #{tag_1}"
  total_bytes_remaining = tag_length - 4
  
  name1, bytes_read = get_string( f )
  # puts "Name1: #{name1}"
  total_bytes_remaining -= bytes_read
  
  total_bytes_remaining.times do
    f.getc
    # puts "lalalalala!"
  end
end

def get_tag( f )
  tag_1 = f.next_n_bits( 8 )
  tag_2 = f.next_n_bits( 8 )
  tag_bit_string = tag_2 + tag_1
  
  tag_code = tag_bit_string.slice(0,10).to_i(2)
  tag_length = tag_bit_string.slice(10,6).to_i(2)

  if tag_length >= 63
    tag_length_1 = f.getc
    tag_length_2 = f.getc
    tag_length_3 = f.getc
    tag_length_4 = f.getc
    tag_length = tag_length_1 + 256*tag_length_2 + 65536*tag_length_3 + 16777216*tag_length_4
  end
  
  return [tag_code, tag_length]
end

def get_dictionary
  return DICTIONARY
end

def define_shape( tag_length, f, version )
  puts "Define Shape #{version} Tag"
  before = f.total_bytes_read
  
  if true
    shape_id_1 = f.getc
    shape_id_2 = f.getc
    shape_id = shape_id_1 + 256*shape_id_2
    # puts "Shape id: #{shape_id}"
    
    shape_bounds = get_rect( f )
    # puts "Shape Bounds: (#{shape_bounds[0]}, #{shape_bounds[2]}), (#{shape_bounds[1]}, #{shape_bounds[3]})"
  
    shape = get_shape_with_style( f )
    shape.bounds = shape_bounds
    shape.id = shape_id
  
    d = get_dictionary
    d[ shape_id ] = shape
  else
    tag_length.times do
      f.getc
    end
  end
  
  after = f.total_bytes_read
  puts "ERROR! difference is: #{after - before}, it should be #{tag_length}" unless (after-before) == tag_length
end

def define_morph_shape( tag_length, f )
  puts "Define Morph Shape"
  
  tag_length.times do
    f.getc
  end
end

def define_shape_4( tag_length, f )
  puts "Define Shape 4"
  
  tag_length.times do
    f.getc
  end
end

def define_shape_3( tag_length, f )
  puts "Define Shape 3"
  
  tag_length.times do
    f.getc
  end
end

def skip_tag( tag_length, f, tag_code )
  puts "-----------------FAIL! unknown tag #{tag_code}-----------------"
  tag_length.times do
    f.getc
  end
end

def metadata( tag_length, f )
  puts "Metadata Tag"
  tag_length.times do
    f.getc
  end
end

def define_sprite( tag_length, f )
  puts "Define Sprite Tag"
  
  sprite = Sprite.new
  
  sprite_id_1 = f.getc
  sprite_id_2 = f.getc
  sprite_id = sprite_id_1 + 256*sprite_id_2
  # puts "Sprite id: #{sprite_id}"
  sprite.id = sprite_id
  
  frame_count_1 = f.getc
  frame_count_2 = f.getc
  frame_count = frame_count_1 + 256*frame_count_2
  # puts "Frame count: #{frame_count}"
  sprite.frame_count = frame_count
  
  num_bytes_remaining = tag_length - 4
  
  num_bytes_remaining.times do
    # puts "what belongs here??"
    f.getc
  end
end

def file_attributes( tag_length, f )
  puts "File Attributes Tag"
  
  tag_length.times do
    f.getc
  end
end

def set_background_color( tag_length, f )
  color = get_rgb(f)
  #puts "Set Background Color to: (#{color[0]}, #{color[1]}, #{color[2]})"
end

def define_scene_and_frame_label_data( tag_length, f )
  puts "Define Scene and Frame Lable Data Tag"
  tag_length.times do
    f.getc
  end
end

def do_abc( tag_length, f )
  puts "Do ABC tag"
  tag_length.times do
    f.getc
  end
end

def show_frame( tag_length, f )
  puts "Show Frame Tag"
  tag_length.times do
    f.getc
  end
end

def end_tag( tag_length, f )
  puts "End Tag"
  tag_length.times do
    f.getc
  end
end

def handle_tag( tag_code, tag_length, f )
  case tag_code
  when 0
    end_tag( tag_length, f )
  when 1
    show_frame( tag_length, f )
  when 2
    define_shape( tag_length, f, 1 )
  when 9
    set_background_color( tag_length, f )
  when 22
    define_shape( tag_length, f, 2 )
  when 32
    define_shape_3( tag_length, f )
  when 39
    define_sprite( tag_length, f )
  when 46
    define_morph_shape( tag_length, f )
  when 69
    file_attributes( tag_length, f )
  when 76
    symbol_class( tag_length, f )
  when 77
    metadata( tag_length, f )
  when 82
    do_abc( tag_length, f )
  when 83
    define_shape_4( tag_length, f )
  when 86
    define_scene_and_frame_label_data( tag_length, f )
  else
    skip_tag( tag_length, f, tag_code )
  end
end

file_stream = File.open(ARGV[0], "r")
f = AdvancedFileReader.new( file_stream )

signature_1 = f.getc
signature_2 = f.getc
signature_3 = f.getc

if signature_1 != 'F'[0]
  raise "Please Export an Uncompressed SWF file"
end

if signature_2 != 'W'[0]
  raise "Expected second byte to be 'W'"
end

if signature_3 != 'S'[0]
  raise "Expected third byte to be 'S'"
end

version = f.getc

# puts "Flash Version: #{version}"

file_size_1 = f.getc
file_size_2 = f.getc
file_size_3 = f.getc
file_size_4 = f.getc

num_bytes_total = (file_size_1 + 256*file_size_2 + 65536*file_size_3 + 16777216*file_size_4)

# puts "Num Bytes total: #{num_bytes_total}"

frame = get_rect(f)

# puts "Frame Size: #{frame[1]/20} x #{frame[3]/20}"

frame_rate_1 = f.getc
frame_rate_2 = f.getc
frame_rate = 0.1*frame_rate_1 + frame_rate_2
# puts "Frame Rate: #{frame_rate}"

frame_count_1 = f.getc
frame_count_2 = f.getc
frame_count = frame_count_1 + 256*frame_count_2
# puts "Frame Count: #{frame_count}"


while !f.eof?
  tag_code, tag_length = get_tag(f)
  handle_tag( tag_code, tag_length, f )
end

f.close


d = get_dictionary
d.each do |key, value|
  puts "Key: #{key}"
  if value.is_a? Shape
    output = File.open("output/#{key}.svg", "w")
    output.write value.to_svg
    output.close
  end
end

