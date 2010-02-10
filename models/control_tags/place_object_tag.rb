class PlaceTag
  attr_accessor :character_id, :depth, :matrix, :color_transform
  
  def to_txt
    path="PLACE TAG\n"
  end
  
  def to_xml
    "<place_tag></place_tag>"
  end
end