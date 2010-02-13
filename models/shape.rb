class Shape
  attr_accessor :fill_styles
  attr_accessor :line_styles
  attr_accessor :shape_records
  attr_accessor :bounds
  attr_accessor :id
  
  def to_svg
    path = shape_records.map{|record| record.to_svg(self) }.join(' ')
    "<?xml version='1.0' standalone='no'?><!DOCTYPE svg PUBLIC '-//W3C//DTD SVG 1.1//EN' 'http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd'><svg width='50cm' height='50cm' viewBox='0 0 100 100' xmlns='http://www.w3.org/2000/svg' version='1.1'>#{path}</svg>"
  end
  
  def to_txt
    path = "SHAPE_ID: #{id} | BOUNDS: (#{bounds.xmin}, #{bounds.ymin}), (#{bounds.xmax}, #{bounds.ymax})\n"
    if(fill_styles.length > 0)
      path += fill_styles.each_with_index.map{|fs, i| "\t[#{i}]" + fs.to_txt}.join("\n")
      path += "\n"
    end
    if(line_styles.length > 0)
      path += line_styles.each_with_index.map{|ls, i| "\t[#{i}]" + ls.to_txt}.join("\n")
      path += "\n"
    end
    path += shape_records.map{|record| "\t" + record.to_txt(self)}.join("\n")
    path += "\n"
  end
  
  def to_xml
    "<shape id='#{self.id}'>
      <bounds>#{self.bounds.to_xml}</bounds>
      #{self.line_styles_xml}
      #{self.fill_styles_xml}
      #{self.shape_records_xml}
    </shape>"
  end
  
  def line_styles_xml
    return_val = "<line_styles>"
    return_val += line_styles.map{ |line_style| line_style.to_xml }.join('')
    return_val += "</line_styles>"
  end
  
  def fill_styles_xml
    return_val = "<fill_styles>"
    return_val += self.fill_styles.map{ |fill_style| fill_style.to_xml }.join('')
    return_val += "</fill_styles>"
  end
  
  def shape_records_xml
    return_val = "<shape_records>"
    return_val += self.shape_records.map{ |shape_record| shape_record.to_xml }.join('')
    return_val += "</shape_records>"
  end
end