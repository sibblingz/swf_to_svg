class LineStyle
  attr_accessor :width, :color
  
  def to_txt
    path="LINE STYLE :: width #{width/20.0} ; color (#{color.r}, #{color.g}, #{color.b})"
  end
end