class LineStyle
  attr_accessor :width, :color
  
  def to_txt
    path="LINE STYLE :: width #{width/20.0} ; color (#{color.r}, #{color.g}, #{color.b})"
  end
  
  def to_xml
    "<line_style width='#{self.width}' #{color.to_xml_attrib} />"
  end
end