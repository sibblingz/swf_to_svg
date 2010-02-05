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
  
end