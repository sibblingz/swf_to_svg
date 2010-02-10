class Tag
  attr_accessor :tag_code, :tag_length, :tag_data, :tag_string
  
  def initialize( tag_code, tag_length, f )
    @tag_code = tag_code
    @tag_length = tag_length
    @tag_data = []
    
    handle_tag( f )
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
"<tag id='#{tag_code}' length='#{tag_length}' name='#{tag_string}'>
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
      when 32
        @tag_string = "DEFINE SHAPE 3"
        define_shape_3( @tag_length, f )
      when 39
        @tag_string = "DEFINE SPRITE"
        define_sprite( @tag_length, f )
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
  
end