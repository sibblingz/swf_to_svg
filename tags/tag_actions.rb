require 'advanced_file_reader.rb'
require 'tags/tag_helpers.rb'
require 'tags/tag.rb'

class Tag
private
# all tags need to "push back" in to tag data
# UNKNOWN TAG CODE
def skip_tag( tag_length, f, tag_code )
  puts "-----------------FAIL! unknown tag #{tag_code}-----------------"
  tag_length.times do
    f.getc
  end
end

# Tag code = 0
def end_tag( tag_length, f )
  before = f.total_bytes_read
  puts "End Tag"
  tag_length.times do
    f.getc
  end
  
  after = f.total_bytes_read
  raise "END TAG ERROR! difference is: #{after - before}, it should be #{tag_length}" unless (after-before) == tag_length
end

# Tag code = 1
def show_frame( tag_length, f )
  before = f.total_bytes_read
  
  sf = ShowTag.new
  puts "Show Frame Tag"
  tag_length.times do
    f.getc
  end
  
  after = f.total_bytes_read
  raise "SHOW FRAME ERROR! difference is: #{after - before}, it should be #{tag_length}" unless (after-before) == tag_length
  @tag_data.push( sf )
end

# Tag code = 2 or 22 or 32 or 83
def define_shape( tag_length, f, version )
  puts "Define Shape #{version} Tag"
  before = f.total_bytes_read
  
  if true
    shape_id = f.get_u16
    puts "Shape id: #{shape_id}"
    puts "getting a rect!"
    puts "buffer: #{f.buffer}"
    shape_bounds = Rect.new( f )
    puts "Shape Bounds: (#{shape_bounds.xmin}, #{shape_bounds.ymin}), (#{shape_bounds.xmax}, #{shape_bounds.ymax})"
     
    now = f.total_bytes_read
    remaining = tag_length - (now-before)

    # remaining.times do
    #       f.getc
    #     end    
        
    shape = get_shape_with_style( f, remaining, version )
    #shape = Shape.new
    shape.bounds = shape_bounds
    shape.id = shape_id
  
    # d = get_dictionary
    #     d[ shape_id ] = shape
        
        #filename = "output/#{shape_id}.svg"
        #puts "writing file #{filename}"
        #output = File.open(filename, "w")
        #output.write shape.to_svg
        #output.close
  else
    tag_length.times do
      f.getc
    end
  end
  
  after = f.total_bytes_read
  raise "ERROR! difference is: #{after - before}, it should be #{tag_length}" unless (after-before) == tag_length
  f.skip_to_next_byte
  @tag_data.push( shape )
end

# Tag code = 4
def place_object( tag_length, f )
  puts "Place Object (Rare Usage)"
  tag_length.times do
    f.getc
  end
end

# Tag code = 9
def set_background_color( tag_length, f )
  before = f.total_bytes_read
  
  puts "Set Background Color"
  color = RGB.new(f)
  #puts "Set Background Color to: (#{color[0]}, #{color[1]}, #{color[2]})"
  
  after = f.total_bytes_read
  raise "SET BACKGROUND COLOR ERROR! difference is: #{after - before}, it should be #{tag_length}" unless (after-before) == tag_length
  
  @tag_data.push( color )
end

# Tag code = 26
def place_object_2( tag_length, f )
  before = f.total_bytes_read
  # puts "bit pattern #{f.next_n_bits(tag_length*8)}"
  # num_segments = tag_length*8/4
  #   num_segments.times do
  #     print "#{f.next_n_bits(4)} "
  #   end
  puts "Place Object 2"
  
  obj2 = PlaceObject2Tag.new
  #puts "#{f.next_n_bits(8)}"
  place_flag_has_clip_actions = f.next_n_bits(1)
  place_flag_has_clip_depth = f.next_n_bits(1)
  place_flag_has_name = f.next_n_bits(1)
  place_flag_has_ratio = f.next_n_bits(1)
  place_flag_has_color_transform = f.next_n_bits(1)
  place_flag_has_matrix = f.next_n_bits(1)
  place_flag_has_character = f.next_n_bits(1)
  place_flag_move = f.next_n_bits(1)
  #puts "AHAHAHAHAHA"
  obj2.depth = f.get_u16
  
  #puts "#{obj2.depth}"
  if(place_flag_has_character == "1")
    obj2.character_id = f.get_u16
  end
  
  if(place_flag_has_matrix == "1")
     obj2.matrix = Matrix.new(f)
  end
  
  if(place_flag_has_color_transform == "1")
    obj2.color_transform = C_XFORM_WITH_ALPHA.new(f)
  end
  
  if(place_flag_has_ratio == "1")
    obj2.ratio = f.get_u16
  end
  
  if(place_flag_has_name == "1")
    # parse as ASCII name
    # spec has UTF-8 encoding....
    obj2.name = SwfMath.parse_ASCII_string( f )
  end
  
  if(place_flag_has_clip_depth == "1")
    obj2.clip_depth = f.get_u16
  end
  
  if(place_flag_has_clip_actions=="1")
    # not implemented
  end
  e = f.total_bytes_read
  read = e-before
  remaining = tag_length - read
  #puts "#{remaining}, #{tag_length}"
  
  # not implemented
  remaining.times do
    f.getc
  end
  #tag_length.times do
  #  f.getc
  #end
  
  after = f.total_bytes_read
  raise "PLACE OBJECT 2 ERROR! difference is: #{after - before}, it should be #{tag_length}" unless (after-before) == tag_length
  
  @tag_data.push( obj2 )
end

# Tag code 28
def remove_object_2( tag_length, f )
  before = f.total_bytes_read
  
  puts "Remove Object 2"
  ro2 = RemoveObject2Tag.new
  ro2.depth = f.get_u16
  
  after = f.total_bytes_read
  raise "REMOVE OBJECT 2 ERROR difference is #{after - before}, it should be #{tag_length}" unless (after-before) == tag_length
  
  @tag_data.push( ro2 )
end

# # Tag code = 32
# def define_shape_3( tag_length, f )
#   puts "Define Shape 3"
#   
#   tag_length.times do
#     f.getc
#   end
# end

# Tag code = 34
def define_button_2( tag_length, f )
  
  puts "Define Button 2 (not implemented!)"
  
  tag_length.times do
    f.getc
  end
  
  # before = f.total_bytes_read
  #   button = DefineButton2Tag.new
  #   
  #   button.id = f.get_u16
  #   
  #   reserved_flags = f.next_n_bits(7)
  #   raise "Error in define button 2 (reserved flags)" unless reserved_flags == '0000000'
  #   
  #   button.track_as_menu = f.next_n_bits(1)
  #   
  #   action_offset = f.get_u16
  #   
  #   characters = []
  #   actions = []
  #   
  #   after = f.total_bytes_read
  #   raise "DEFINE BUTTON 2 ERROR! difference is: #{after - before}, it should be #{tag_length}" unless (after-before) == tag_length
  
end

# Tag code = 39
def define_sprite( tag_length, f )
  before = f.total_bytes_read
  my_tag_length = tag_length
  
  puts "Define Sprite Tag"
  
  sprite = Sprite.new
  
  #sprite_id_1 = f.getc
  #sprite_id_2 = f.getc
  sprite_id = f.get_u16 #sprite_id_1 + 256*sprite_id_2
  # puts "Sprite id: #{sprite_id}"
  sprite.id = sprite_id
  
  #frame_count_1 = f.getc
  #frame_count_2 = f.getc
  frame_count = f.get_u16#frame_count_1 + 256*frame_count_2
  # puts "Frame count: #{frame_count}"
  sprite.frame_count = frame_count

  sprite.control_tags = []
  
  begin 
#   f.skip_to_next_byte
    tag_code, tag_length = get_tag(f)
    
    tag = Tag.new(tag_code, tag_length, f)
    
    sprite.control_tags.push( tag )
    
  end while tag_code != 0 
#puts sprite.control_tags
  #num_bytes_remaining = tag_length - 4
  
  #num_bytes_remaining.times do
    # puts "what belongs here??"
  #  f.getc
  #end
  #f.skip_to_next_byte
  
  after = f.total_bytes_read
  raise "DEFINE SPRITE ERROR! difference is: #{after - before}, it should be #{my_tag_length}" unless (after-before) == my_tag_length

  @tag_data.push( sprite )
end

# Tag code = 43
def frame_label( tag_length, f )
  
  flabel = FrameLabelTag.new
  flabel.frame_label, bytes_read = SwfMath.parse_ASCII_string( f )
  
  @tag_data.push( flabel )
end

# Tag code = 46
def define_morph_shape( tag_length, f )
  puts "Define Morph Shape"
  
  tag_length.times do
    f.getc
  end
end

# Tag code = 69
def file_attributes( tag_length, f )
  puts "File Attributes Tag (not implemented)"
  
  tag_length.times do
    f.getc
  end
end

# Tag code = 70
def place_object_3( tag_length, f )
  puts "Place Object 3 (not implemented)"
  
  tag_length.times do
    f.getc
  end
end

# Tag code = 75
def define_font_3( tag_length, f )
  puts "Define Font 3 (not implemented)"
  
  tag_length.times do
    f.getc
  end
end

# Tag code = 76
def symbol_class( tag_length, f )
  puts "Symbol Class Tag"
  
  symbol = SymbolClassTag.new
  
  num_symbols = f.get_u16
  symbol.num_symbols = num_symbols
  #puts "Num Symbols: #{num_symbols}"
  
  tag_ids = []
  tag_names = []
  num_symbols.times do
    tag_id = f.get_u16
    #puts "Tag1: #{tag_1}"
    #total_bytes_remaining = tag_length - 4
  
    name, bytes_read = SwfMath.parse_ASCII_string( f )
    puts "#{name}"
    tag_ids.push( tag_id )
    tag_names.push( name )
    #get_string( f )
  end
  
  symbol.tag_ids = tag_ids
  symbol.tag_names = tag_names
  
  #puts "Name1: #{name1}"
  #total_bytes_remaining -= bytes_read
  
  #total_bytes_remaining.times do
  #  f.getc
    # puts "lalalalala!"
  #end
  @tag_data.push( symbol )
end

# Tag code = 77
def metadata( tag_length, f )
  puts "Metadata Tag"
  tag_length.times do
    f.getc
  end
end

# Tag code = 82
def do_abc( tag_length, f )
  puts "Do ABC tag"
  tag_length.times do
    f.getc
  end
end

# Tag code = 83
def define_shape_4( tag_length, f )
  puts "Define Shape 4"
  
  tag_length.times do
    f.getc
  end
end

# Tag code = 86
def define_scene_and_frame_label_data( tag_length, f )
  puts "Define Scene and Frame Label Data Tag"
  tag_length.times do
    f.getc
  end
end

end