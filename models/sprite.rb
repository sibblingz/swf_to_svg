class Sprite
  attr_accessor :id, :frame_count, :control_tags
  
  def to_txt
    path = "SPRITE: #{id} | FRAME COUNT: #{frame_count}"
    path += control_tags.map{|tags| "    " + tags.to_txt }.join('
      ')
  end
end