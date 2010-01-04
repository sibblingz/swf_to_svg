class Shape
  attr_accessor :fill_styles
  attr_accessor :line_styles
  attr_accessor :shape_records
  attr_accessor :bounds
  attr_accessor :id
  
  def to_svg
    path = shape_records.map{|record| record.to_svg(self) }.join(' ')
    "<?xml version='1.0' standalone='no'?><!DOCTYPE svg PUBLIC '-//W3C//DTD SVG 1.1//EN' 'http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd'><svg width='10cm' height='10cm' viewBox='0 0 200 200' xmlns='http://www.w3.org/2000/svg' version='1.1'>#{path}</svg>"
  end
end