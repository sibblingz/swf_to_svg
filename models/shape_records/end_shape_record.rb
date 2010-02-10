class EndShapeRecord
  
  
  def to_svg( shape )
    "z' />"
  end
  
  def to_txt ( shape )
    path = "END SHAPE RECORD"
  end
  
  def to_xml
    "<end_shape_record></end_shape_record>"
  end
end