class Tag
  attr_accessor :tag_code, :tag_length, :tag_data, :tag_string
  
  def initialize( tag_code, tag_length, f )
    @tag_code = tag_code
    @tag_length = tag_length
    @tag_data = []
    
    #puts "tag starts on #{f.total_bytes_read}, buffer is #{f.buffer}"
    handle_tag( f )
    #skip_all_tag_data( f )
  end
  
  def to_txt_all
    path = "===========BEGIN TAG=============\n"
    path += "#{tag_string}\nID: #{tag_code} | LENGTH: #{tag_length}\n"
    path += tag_data.map{|data| "\n" + data.to_txt }.join("\n")
    path +="============END TAG==============\n\n"
  end
  
  def to_txt(modifier)
    path = ">> BEGIN #{modifier} TAG <<\n"
    path += "#{tag_string}\nID: #{tag_code} | LENGTH: #{tag_length}\n"
    path += tag_data.map{|data| "\n" + data.to_txt }.join("\n")
    path +=">> END #{modifier} TAG <<\n\n"
  end
  
  def to_xml
"<tag code='#{tag_code}' name='#{tag_string}'>
  <tag_data>
    #{ tag_data.map{ |data| data.to_xml }.join("\n") }
  </tag_data>
</tag>\n"
  end
  
  private
  
    def handle_tag( f )
      @tag_string = case @tag_code
      when 0
        end_tag( @tag_length, f )
        "END TAG"
      when 1
        show_frame( @tag_length, f )
        "SHOW FRAME"
      when 2
        define_shape( @tag_length, f, 1 )
        "DEFINE SHAPE"
      when 4
        place_object( @tag_length, f )
        "PLACE OBJECT (not implemented)"
      when 6
        skip_tag( @tag_length, f, @tag_code )
        "DEFINE BITS (not needed?)"
      when 8
        skip_tag( @tag_length, f, @tag_code )
        "JPEG TABLES (not needed?)"
      when 9
        set_background_color( @tag_length, f )
        "SET BACKGROUND COLOR"
      when 11
        skip_tag( @tag_length, f, @tag_code )
        "DEFINE TEXT (not implemented)"
      when 20
        skip_tag( @tag_length, f, @tag_code )
        "DEFINE BITS LOSSLESS (not needed?)"
      when 22
        define_shape( @tag_length, f, 2 )
        "DEFINE SHAPE 2"
      when 26
        place_object_2( @tag_length, f )
        "PLACE OBJECT 2"
      when 28
        remove_object_2( @tag_length, f )
        "REMOVE OBJECT 2"
      when 32
        define_shape( @tag_length, f, 3 )
        "DEFINE SHAPE 3"
      when 34
        define_button_2( @tag_length, f )
        "DEFINE BUTTON 2 (not implemented)"
      when 37
        skip_tag( @tag_length, f, @tag_code )
        "DEFINE EDIT TEXT (not implemented)"
      when 39
        define_sprite( @tag_length, f )
        "DEFINE SPRITE"
      when 43
        frame_label( @tag_length, f )
        "FRAME LABEL"
      when 46
        define_morph_shape( @tag_length, f )
        "DEFINE MORPH SHAPE (not implemented)"
      when 64
        skip_tag( @tag_length, f, @tag_code )
        "ENABLE DEBUGGER 2 (not needed)"
      when 69
        file_attributes( @tag_length, f )
        "FILE ATTRIBUTES (not needed)"
      when 70
        place_object_3( @tag_length, f )
        "PLACE OBJECT 3 (not implemented)"
      when 73
        skip_tag( @tag_length, f, @tag_code )
        "DEFINE FONT ALIGN ZONES (not implemented)"
      when 74
        skip_tag( @tag_length, f, @tag_code )
        "CSM TEXT SETTINGS (not implemented)"
      when 75
        define_font_3( @tag_length, f )
        "DEFINE FONT 3 (not implemented)"
      when 76
        symbol_class( @tag_length, f )
        "SYMBOL CLASS"
      when 77
        metadata( @tag_length, f )
        "METADATA (not needed)"
      when 78
        skip_tag( @tag_length, f, @tag_code )
        "DEFINE SCALING GRID (not needed?)"
      when 82
        do_abc( @tag_length, f )
        "DO ABC (not implemented)"
      when 83
        define_shape_4( @tag_length, f )
        "DEFINE SHAPE 4 (not implemented)"
      when 86
        define_scene_and_frame_label_data( @tag_length, f )
        "DEFINE SCENE AND FRAME LABEL DATA (not implemented)"
      when 88
        skip_tag( @tag_length, f, @tag_code )
        "DEFINE FONT NAME (not implemented)"
      else
        skip_tag( @tag_length, f, @tag_code )
        "UNKNOWN TAG"
      end
    end
    
    def skip_all_tag_data( f )
      @tag_string = case @tag_code
      when 0
        "END TAG"
      when 1
        "SHOW FRAME"
      when 2
        "DEFINE SHAPE"
      when 4
        "PLACE OBJECT"
      when 9
        "SET BACKGROUND COLOR"
      when 22
        "DEFINE SHAPE 2"
      when 26
        "PLACE OBJECT 2"
      when 28
        "REMOVE OBJECT 2"
      when 32
        "DEFINE SHAPE 3"
      when 39
        "DEFINE SPRITE"
      when 46
        "DEFINE MORPH SHAPE"
      when 69
        "FILE ATTRIBUTES"
      when 76
        "SYMBOL CLASS"
      when 77
        "METADATA"
      when 82
       "DO ABC"
      when 83
        "DEFINE SHAPE 4"
      when 86
        "DEFINE SCENE AND FRAME LABEL DATA"
      else
        "UNKNOWN TAG"
      end
      
      @tag_length.times do
        f.getc
      end
    end
  
end