class Sprite
  attr_accessor :id, :frame_count, :control_tags
  
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