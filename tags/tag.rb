class Tag
  attr_accessor :tag_code, :tag_length, :tag_data
  
  def initialize( tag_code, tag_length, f )
    @tag_code = tag_code
    @tag_length = tag_length
    @tag_data = []
    
    handle_tag( f )
  end
  
  def to_txt
    path = "TAG: #{tag_code} | LENGTH: #{tag_length}"
    path += tag_data.map{|data| "    " + data.to_txt }.join('
      ')
  end
  
  private
  
    def handle_tag( f )
      case @tag_code
      when 0
        end_tag( @tag_length, f )
      when 1
        show_frame( @tag_length, f )
      when 2
        define_shape( @tag_length, f, 1 )
      when 4
        place_object( @tag_length, f )
      when 9
        set_background_color( @tag_length, f )
      when 22
        define_shape( @tag_length, f, 2 )
      when 26
        place_object_2( @tag_length, f )
      when 32
        define_shape_3( @tag_length, f )
      when 39
        define_sprite( @tag_length, f )
      when 46
        define_morph_shape( @tag_length, f )
      when 69
        file_attributes( @tag_length, f )
      when 76
        symbol_class( @tag_length, f )
      when 77
        metadata( @tag_length, f )
      when 82
        do_abc( @tag_length, f )
      when 83
        define_shape_4( @tag_length, f )
      when 86
        define_scene_and_frame_label_data( @tag_length, f )
      else
        skip_tag( @tag_length, f, @tag_code )
      end
    end
  
end