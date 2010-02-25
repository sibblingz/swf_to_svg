require 'tags/tag_classes.rb'
require 'tags/tag_records.rb'
require 'zlib'


class Tag
  attr_accessor :tag_code, :tag_length, :tag_data, :tag_string, :f
  
  def self.read( tag_code, tag_length, f )
    tag = self.new
    
    tag.tag_code = tag_code
    tag.tag_length = tag_length
    tag.f = f
    tag.tag_data = []
    
    tag.handle_tag
    
    return tag
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
 

  def handle_tag
    # in the process of making these .read calls instead of function calls...
    @tag_string = case @tag_code
    when 0
      EndTag.read( self ) # no data
      "END TAG"
    when 1
      ShowFrameTag.read( self )  # no data
      "SHOW FRAME"
    when 2
      ShapeTag.read( self, 1 )
      "DEFINE SHAPE"
    when 4
      #place_object( @tag_length, f )
      skip_tag
      "PLACE OBJECT (not implemented)"
    when 6
      skip_tag
      "DEFINE BITS (not needed?)"
    when 8
      skip_tag
      "JPEG TABLES (not needed?)"
    when 9
      SetBackgroundColorTag.read( self )
      "SET BACKGROUND COLOR"
    when 11
      skip_tag
      "DEFINE TEXT (not implemented)"
    when 20
      skip_tag
      "DEFINE BITS LOSSLESS (not needed?)"
    when 22
      ShapeTag.read( self, 2 )
      #skip_tag
      "DEFINE SHAPE 2"
    when 26
      #place_object_2( @tag_length, f )
      PlaceObject2Tag.read( self )
      "PLACE OBJECT 2"
    when 28
      RemoveObject2Tag.read( self )
      "REMOVE OBJECT 2"
    when 32
      ShapeTag.read( self, 3 )
      "DEFINE SHAPE 3"
    when 34
      #define_button_2( @tag_length, @f )
      skip_tag
      "DEFINE BUTTON 2 (not implemented)"
    when 37
      skip_tag
      "DEFINE EDIT TEXT (not implemented)"
    when 39
      SpriteTag.read( self )
      "DEFINE SPRITE"
    when 43
      FrameLabelTag.read( self )
      "FRAME LABEL"
    when 46
      #define_morph_shape( @tag_length, f )
      MorphShapeTag.read( self, 1 )
      "DEFINE MORPH SHAPE"
    when 64
      skip_tag
      "ENABLE DEBUGGER 2 (not needed)"
    when 69
      skip_tag
      #file_attributes( @tag_length, f )
      "FILE ATTRIBUTES (not needed)"
    when 70
      #place_object_3( @tag_length, @f )
      skip_tag
      "PLACE OBJECT 3 (not implemented)"
    when 73
      skip_tag
      "DEFINE FONT ALIGN ZONES (not implemented)"
    when 74
      skip_tag
      "CSM TEXT SETTINGS (not implemented)"
    when 75
      #define_font_3( @tag_length, @f )
      skip_tag
      "DEFINE FONT 3 (not implemented)"
    when 76
      SymbolClassTag.read( self )
      "SYMBOL CLASS"
    when 77
      #metadata( @tag_length, f )
      skip_tag
      "METADATA (not needed)"
    when 78
      skip_tag
      "DEFINE SCALING GRID (not needed?)"
    when 82
      #do_abc( @tag_length, f )
      skip_tag
      "DO ABC (not implemented)"
    when 83
      #define_shape_4( @tag_length, @f )
      #skip_tag
      ShapeTag.read( self, 4 )
      "DEFINE SHAPE 4"
    when 86
      #define_scene_and_frame_label_data( @tag_length, f )
      skip_tag
      "DEFINE SCENE AND FRAME LABEL DATA (not implemented)"
    when 88
      skip_tag
      "DEFINE FONT NAME (not implemented)"
    else
      skip_tag
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
  
  def skip_tag 
    puts "-----------------Skipping tag #{tag_code}-----------------"
    @tag_length.times do
      f.getc
    end
    @tag_data = []
  end
  
end