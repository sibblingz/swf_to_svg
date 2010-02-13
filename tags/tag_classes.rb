class SymbolClassTag
  attr_accessor :num_symbols, :tag_ids, :tag_names
  
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

class ShowTag
  def to_txt
    path="SHOW TAG\n"
  end
  
  def to_xml
    "<show_tag/>"
  end
end

class PlaceTag
  attr_accessor :character_id, :depth, :matrix, :color_transform
  
  def to_txt
    path="PLACE TAG\n"
  end
  
  def to_xml
    "<place_tag/>"
  end
end

class PlaceObject2Tag
  attr_accessor :depth, :character_id, :matrix, :color_transform, :ratio, :name, :clip_depth, :clip_actions
  
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

class FrameLabel
  attr_accessor :frame_label
  
  def to_xml
    "<frame_label name='#{frame_label}'/>"
  end
end