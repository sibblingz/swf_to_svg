
class SymbolClassTag
  attr_accessor :num_symbols, :tag_ids, :tag_names
  
  def self.read( tag )
    f = tag.f
    tag_length = tag.tag_length
    
    symbol = self.new
    before = f.total_bytes_read
    
    num_symbols = f.get_u16
    symbol.num_symbols = num_symbols
    #puts "Num Symbols: #{num_symbols}"

    tag_ids = []
    tag_names = []
    num_symbols.times do
      tag_id = f.get_u16
      #puts "Tag1: #{tag_1}"
      #total_bytes_remaining = tag_length - 4

      name, bytes_read = f.get_string
      puts "#{name}"
      tag_ids.push( tag_id )
      tag_names.push( name )
      #get_string( f )
    end

    symbol.tag_ids = tag_ids
    symbol.tag_names = tag_names
    
    after = f.total_bytes_read
    
    raise "ERROR IN READING SYMBOL CLASS TAG" unless (after - before) == tag_length
    
    tag.tag_data.push( symbol )
  end
  
  def to_xml
    "<symbols num='#{num_symbols}'>
      #{tags_to_xml}
     </symbols>"
  end
  private
    def tags_to_xml
      return_val = tag_ids.each_with_index.map{ |id, i| "<symbol tag_id='#{id}' name='#{tag_names[i]}'/>" }.join("\n")
    end
end

# Tag code = 0
class EndTag
  # returns nothing
  def self.read( tag )
    f = tag.f
    tag_length = tag.tag_length
    
    before = f.total_bytes_read
    puts "End Tag"
    tag_length.times do
      f.getc
    end

    after = f.total_bytes_read
    raise "END TAG ERROR! difference is: #{after - before}, it should be #{tag_length}" unless (after-before) == tag_length
    
    tag.tag_data = []
  end
end
# Tag code = 1
class ShowFrameTag
  
  def self.read( tag )
    f = tag.f
    tag_length = tag.tag_length
    
    # returns nothing
    before = f.total_bytes_read

    #sf = self.new
    #puts "Show Frame Tag"
    tag_length.times do
      f.getc
    end

    after = f.total_bytes_read
    raise "SHOW FRAME ERROR! difference is: #{after - before}, it should be #{tag_length}" unless (after-before) == tag_length
    
    tag.tag_data = []
    #return sf
  end
  
  def to_txt
    path="SHOW FRAME\n"
  end
  
  def to_xml
    "<show_frame/>"
  end
end

# Tag code = 2, 22, or 32
class ShapeTag
  attr_accessor :fill_styles
  attr_accessor :line_styles
  attr_accessor :shape_records
  attr_accessor :bounds
  attr_accessor :id
  
  def self.read( tag, version )
    f = tag.f
    tag_length = tag.tag_length
    
    #puts "Define Shape #{version} Tag"
    before = f.total_bytes_read
 
    if true
      shape_id = f.get_u16
      #puts "Shape id: #{shape_id}"
      #puts "getting a rect!"
      #puts "buffer: #{f.buffer}"
      shape_bounds = Rect.read( f )
      #puts "Shape Bounds: (#{shape_bounds.xmin}, #{shape_bounds.ymin}), (#{shape_bounds.xmax}, #{shape_bounds.ymax})"
 
      now = f.total_bytes_read
      remaining = tag_length - (now-before)
 
      # remaining.times do
      #              f.getc
      #            end    
 
      shape = self.get_shape_with_style( f, remaining, version )
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
    #f.skip_to_next_byte
    
    tag.tag_data.push( shape )
  end
  
  def to_svg
    path = shape_records.map{|record| record.to_svg(self) }.join(' ')
    "<?xml version='1.0' standalone='no'?><!DOCTYPE svg PUBLIC '-//W3C//DTD SVG 1.1//EN' 'http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd'><svg width='50cm' height='50cm' viewBox='0 0 100 100' xmlns='http://www.w3.org/2000/svg' version='1.1'>#{path}</svg>"
  end
  
  def to_txt
    path = "SHAPE_ID: #{id} | BOUNDS: (#{bounds.xmin}, #{bounds.ymin}), (#{bounds.xmax}, #{bounds.ymax})\n"
    if(fill_styles.length > 0)
      path += fill_styles.each_with_index.map{|fs, i| "\t[#{i}]" + fs.to_txt}.join("\n")
      path += "\n"
    end
    if(line_styles.length > 0)
      path += line_styles.each_with_index.map{|ls, i| "\t[#{i}]" + ls.to_txt}.join("\n")
      path += "\n"
    end
    path += shape_records.map{|record| "\t" + record.to_txt(self)}.join("\n")
    path += "\n"
  end
  
  def to_xml
    "<shape id='#{self.id}'>
      <bounds>#{self.bounds.to_xml}</bounds>
      #{self.line_styles_xml}
      #{self.fill_styles_xml}
      #{self.shape_records_xml}
    </shape>"
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
  
  def shape_records_xml
    if(@shape_records)
    return_val = "<shape_records>"
    return_val += self.shape_records.map{ |shape_record| shape_record.to_xml }.join('')
    return_val += "</shape_records>"
  else
    ""
  end
  end
  
  
 
  def self.get_fill_style_array( f, v )
    #f.skip_to_next_byte
    #puts "getting fill style array"
    fill_style_count = f.get_u8

    if fill_style_count == 255
      #puts "extended fill style"
      #fill_style_count_extended_1 = f.getc
      #fill_style_count_extended_2 = f.getc
      fill_style_count = f.get_u16 #fill_style_count + 256*fill_style_count_extended_1
    end
    #puts "Num Fill Styles: #{fill_style_count}"
 
    fill_styles = []
    fill_style_count.times do
      fill_style = FillStyle.read( f, v )
      fill_styles.push( fill_style )
    end
    # puts "fill styles array: #{fill_styles.inspect}"
    #f.skip_to_next_byte
    return fill_styles
  end
 
 
 
  def self.get_line_style_array( f, v )
    #f.skip_to_next_byte
 
    #puts "getting line style array"
    line_style_count = f.get_u8
 
    if line_style_count == 255
      #puts "extended line style count"
      #line_style_count_extended_1 = f.getc
      #line_style_count_extended_2 = f.getc
      line_style_count = f.get_u16#line_style_count_extended_1 + 256*line_style_count_extended_2
    end
 
    #puts "Num Line Styles: #{line_style_count}"
 
    line_styles = []
    line_style_count.times do
      if (v <= 3 )
        line_style = LineStyle.read( f, v )
      else
        # get line style 2
      end
      line_styles.push( line_style )
    end
    # puts "line styles array: #{line_styles.inspect}"
    #f.skip_to_next_byte
    return line_styles
  end
 
  def self.get_shape_record( f, num_fill_bits, num_line_bits, v )
    # puts "getting shape record"
    #f.skip_to_next_byte   # shape records are byte aligned
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
      
      flags = state_new_styles_flag + state_line_style_flag + state_fill_style_1_flag + state_fill_style_0_flag + state_move_to_flag
 
#puts flags
      if flags == "00000"
        #puts "End Shape Record"
        shape_record = EndShapeRecord.read( flags, f )
        #f.skip_to_next_byte
      else
        #puts "Style Change Record #{tmp}"
        #puts "before: #{num_line_bits}"
        shape_record = StyleChangeRecord.read( flags, f, v, num_fill_bits, num_line_bits )
        num_fill_bits = shape_record.num_fill_bits
        num_line_bits = shape_record.num_line_bits
        #puts "after: #{num_line_bits}"
        #puts "#{num_fill_bits}, #{num_line_bits}"
      end
    
    else
 
      straight_flag = f.next_n_bits(1)
 
      if straight_flag == '1'
        #puts "Straight Edge Record"
        shape_record = StraightEdgeRecord.read( f )
      else
        #puts "Curved Edge Record"
        shape_record = CurvedEdgeRecord.read( f )
      end
    end
 
    #f.skip_to_next_byte # shape records are byte aligned
    return shape_record, num_fill_bits, num_line_bits
  end
 
  def self.get_shape_with_style( f, l, v )
    #f.skip_to_next_byte
    before = f.total_bytes_read
    s = self.new
 
 #puts "here"
    fill_styles = self.get_fill_style_array( f, v ) 
    s.fill_styles = fill_styles
 
  #  f.skip_to_next_byte
 
    line_styles = self.get_line_style_array( f, v )
    s.line_styles = line_styles
 #puts "here"
    #f.skip_to_next_byte
    num_fill_bits = f.next_n_bits(4).to_i(2)
    num_line_bits = f.next_n_bits(4).to_i(2)
 
    now = f.total_bytes_read
    remaining = l - (now-before)
 
 
    shape_records = []
    total_len = 0
    while true
        before = f.total_bytes_read
 
        shape_record, num_fill_bits, num_line_bits = self.get_shape_record( f, num_fill_bits, num_line_bits, v )

        after = f.total_bytes_read
        total_len = total_len + (after - before)
 
        shape_records.push shape_record
        break if shape_record.is_a? EndShapeRecord
     end
 
     raise "total len and remaining are not equal! total #{total_len} rem #{remaining}" unless total_len == remaining
 
    #f.skip_to_next_byte
 
 
    s.shape_records = shape_records
 
    return s
  end
 
end
#Tag code = 9
class SetBackgroundColorTag
  attr_accessor :color
  
  def self.read( tag )
    f = tag.f
    tag_length = tag.tag_length
    
    sbkgrd = self.new
    
    before = f.total_bytes_read

    #puts "Set Background Color"
    sbkgrd.color = RGB.read( f )
    #puts "Set Background Color to: (#{color[0]}, #{color[1]}, #{color[2]})"

    after = f.total_bytes_read
    raise "SET BACKGROUND COLOR ERROR! difference is: #{after - before}, it should be #{tag_length}" unless (after-before) == tag_length
    
    tag.tag_data.push( sbkgrd )
  end
  
  def to_xml
    "#{color.to_xml}"
  end
  
end

class RemoveObject2Tag
  attr_accessor :depth
  
  def self.read( tag )
    f = tag.f
    tag_length = tag.tag_length
    
    ro2 = self.new
    before = f.total_bytes_read

    ro2.depth = f.get_u16

    after = f.total_bytes_read
    raise "REMOVE OBJECT 2 ERROR difference is #{after - before}, it should be #{tag_length}" unless (after-before) == tag_length
    
    tag.tag_data.push( ro2 )
  end
  
  def to_xml
    "<remove_object_2 depth='#{depth}'/>"
  end
end

class PlaceObjectTag
  attr_accessor :character_id, :depth, :matrix, :color_transform
  
  def to_txt
    path="PLACE OBJECT TAG\n"
  end
  
  def to_xml
    "<place_object/>"
  end
end

# Tag code 26
class PlaceObject2Tag
  attr_accessor :depth, :character_id, :matrix, :color_transform, :ratio, :name, :clip_depth, :clip_actions
  
  def self.read( tag )
    f = tag.f
    tag_length = tag.tag_length
    
    before = f.total_bytes_read
    # puts "bit pattern #{f.next_n_bits(tag_length*8)}"
    # num_segments = tag_length*8/4
    #   num_segments.times do
    #     print "#{f.next_n_bits(4)} "
    #   end
    #puts "Place Object 2"

    obj2 = self.new
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
       obj2.matrix = Matrix.read(f)
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
      obj2.name = f.get_string
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
    
    tag.tag_data.push( obj2 )
  end
  
  def to_txt
    path = "PLACE OBJECT 2 TAG ::"
    
    if @character_id
      path += " id #{character_id}"
    end
    
    if @depth
      path += " depth #{depth}"
    end
    
    if @ratio
      path += " ratio #{ratio}"
    end
    
    if @name
      path += " name #{name}"
    end
    
    if @clip_depth
      path += " clip depth #{clip_depth}"
    end
    path += "\n"
    if @matrix
      path += "\n" + @matrix.to_txt
    end
    if @color_transform
      path += "\n" + @color_transform.to_txt
    end
    
    if @matrix || @color_transform
      path += "\n"
    end
    
    return path
  end
  
  def to_xml
    "<place_object_2 id = '#{character_id}' depth='#{depth}' ratio='#{ratio}' name='#{name}' clip_depth='#{clip_depth}'>
      #{matrix.to_xml}
      #{color_transform.to_xml}
     </place_object_2>"
  end
  
end

class FrameLabelTag
  attr_accessor :frame_label
  
  def self.read( tag )
    f = tag.f
    tag_length = tag.tag_length
    
    before = f.total_bytes_read
    
    flabel = self.new
    flabel.frame_label, bytes_read = f.get_string

    after = f.total_bytes_read
    
    raise "ERROR IN FRAME LABEL DATA" unless (after - before) == tag_length
    
    tag.tag_data.push( flabel )
  end
  
  def to_xml
    "<frame_label name='#{frame_label}'/>"
  end
end

class SpriteTag
  attr_accessor :id, :frame_count, :control_tags
  
  def self.read( tag )
    f = tag.f
    tag_length = tag.tag_length
    
    before = f.total_bytes_read
    
    puts "Define Sprite Tag"

    sprite = self.new

    sprite.id = f.get_u16 
    sprite.frame_count = f.get_u16

    sprite.control_tags = []

    begin 
      my_tag_code, my_tag_length = f.get_tag

      tag = Tag.read( my_tag_code, my_tag_length, f )

      sprite.control_tags.push( tag )

    end while my_tag_code != 0 

    after = f.total_bytes_read
    raise "DEFINE SPRITE ERROR! difference is: #{after - before}, it should be #{my_tag_length}" unless (after-before) == tag_length
    
    tag.tag_data.push( sprite )
  end
  
  def to_txt
    path = "SPRITE: #{id} | FRAME COUNT: #{frame_count}\n"
    path += control_tags.map{|tags| tags.to_txt("CONTROL") }.join("\n")
    path += "\n"
  end
  
  def to_xml
"<sprite id='#{self.id}' frame_count='#{self.frame_count}'>
  #{control_tags_xml}
 </sprite>"
  end
  
  def control_tags_xml
    return_val = "<control_tag>"
    return_val += control_tags.map{ |tags| tags.to_xml }.join("\n")
    return_val += "</control_tag>"
  end
end

class MorphShapeTag
  attr_accessor :character_id, :start_bounds, :end_bounds, :morph_fill_styles, :morph_line_styles
  attr_accessor :start_edges, :end_edges
  
  def self.read( tag, version )
    raise "unsupported morph shape version #{version}" unless version == 1
    before  = tag.f.total_bytes_read
    f = tag.f
  
    mst = self.new
    
    mst.character_id = f.get_u16
    mst.start_bounds = Rect.read( f )
    mst.end_bounds = Rect.read( f )
    
    offset = f.get_u32
    atoff = f.total_bytes_read
    #puts "#{f.total_bytes_read-before}"
        
    mst.morph_fill_styles = MorphFillStyleArray.read( f )
    mst.morph_line_styles = MorphLineStyleArray.read( f, version )
    
    mst.start_edges = Shape.read( f )
    f.skip_to_next_byte
    raise "wrong offset in MORPH SHAPE TAG" unless f.total_bytes_read-atoff == offset
    mst.end_edges = Shape.read( f )
    
    after = tag.f.total_bytes_read
    raise "error in MORPH SHAPE TAG" unless (after-before) == tag.tag_length
    tag.tag_data.push( mst )
  end
  
  def to_xml
    "<morph_shape id = '#{self.character_id}'>
      <start_bounds> #{self.start_bounds.to_xml} </start_bounds>
      <end_bounds> #{self.end_bounds.to_xml} </end_bounds>
      #{morph_fill_styles.to_xml}
      #{morph_line_styles.to_xml}
      <start_edges>#{start_edges.to_xml}</start_edges>
      <end_edges>#{end_edges.to_xml}</end_edges>
    </morph_shape>"
  end
end




# not finished implementing
class DefineButton2Tag
  attr_accessor :id, :track_as_menu, :characters, :actions
  
  def to_xml
    "<button2 button_id='#{id}' track_as_menu='#{track_as_menu}'>
      #{characters.map{ |c| c.to_xml } }
      #{actions.map{ |a| a.to_xml } }
      </button2>"
  end
end

class ButtonRecord
end

class ButtonCondAction
end

# sprite and shape belong in here... just a minor housekeeping

class NilClass
  def to_xml
    ""
  end
end