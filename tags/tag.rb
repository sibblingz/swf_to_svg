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
      case @tag_code
      when 0
        @tag_string = "END TAG"
        end_tag( @tag_length, f )
      when 1
        @tag_string = "SHOW FRAME"
        show_frame( @tag_length, f )
      when 2
        @tag_string = "DEFINE SHAPE"
        define_shape( @tag_length, f, 1 )
      when 4
        @tag_string = "PLACE OBJECT"
        place_object( @tag_length, f )
      when 9
        @tag_string ="SET BACKGROUND COLOR"
        set_background_color( @tag_length, f )
      when 22
        @tag_string = "DEFINE SHAPE 2"
        define_shape( @tag_length, f, 2 )
      when 26
        @tag_string = "PLACE OBJECT 2"
        place_object_2( @tag_length, f )
      when 28
        @tag_string = "REMOVE OBJECT 2"
        remove_object_2( @tag_length, f )
      when 32
        @tag_string = "DEFINE SHAPE 3"
        define_shape( @tag_length, f, 3 )
      when 39
        @tag_string = "DEFINE SPRITE"
        define_sprite( @tag_length, f )
      when 43
        @tag_string = "FRAME LABEL"
        frame_label( @tag_length, f )
      when 46
        @tag_string = "DEFINE MORPH SHAPE"
        define_morph_shape( @tag_length, f )
      when 69
        @tag_string = "FILE ATTRIBUTES"
        file_attributes( @tag_length, f )
      when 76
        @tag_string = "SYMBOL CLASS"
        symbol_class( @tag_length, f )
      when 77
        @tag_string = "METADATA"
        metadata( @tag_length, f )
      when 82
        @tag_string = "DO ABC"
        do_abc( @tag_length, f )
      when 83
        @tag_string = "DEFINE SHAPE 4"
        define_shape_4( @tag_length, f )
      when 86
        @tag_string = "DEFINE SCENE AND FRAME LABEL DATA"
        define_scene_and_frame_label_data( @tag_length, f )
      else
        @tag_string = ">> ERROR! UNKNOWN TAG! <<"
        skip_tag( @tag_length, f, @tag_code )
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
        ">> ERROR! UNKNOWN TAG! <<"
      end
      
      @tag_length.times do
        f.getc
      end
    end
  
end