class Sprite
  attr_accessor :id, :frame_count, :control_tags
  
  def to_txt
    path = "SPRITE: #{id} | FRAME COUNT: #{frame_count}\n"
    path += control_tags.map{|tags| tags.to_txt("CONTROL") }.join("\n")
    path += "\n"
  end
end