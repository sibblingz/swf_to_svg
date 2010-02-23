class FillStyle
  attr_accessor :fill_style_type, :color, :gradient_matrix, :gradient, :bitmap_id, :bitmap_matrix
  
  def to_txt
    what_fill_style
    path ="FILL STYLE :: #{fill_style_type_txt} (#{fill_style_type}) -> color (#{color.r}, #{color.g}, #{color.b})"
  end
  
  def to_xml
    return case self.fill_style_type
    when 0
      "<fill_style type='#{self.fill_style_type}' name='#{fill_style_type_txt}' #{color.to_xml_attrib} />"
    when '10'.to_i(16), '12'.to_i(16)
"<fill_style type='#{self.fill_style_type}' name='#{fill_style_type_txt}'>
  #{self.gradient_matrix.to_xml}
  #{self.gradient.to_xml}
</fill_style>"
    when '40'.to_i(16), '41'.to_i(16), '42'.to_i(16), '43'.to_i(16)
"<fill_style type='#{self.fill_style_type}' name='#{fill_style_type_txt}' bitmap_id='#{bitmap_id}'>
  #{self.bitmap_matrix.to_xml}
</fill_style>"
    else
      "<fill_style type='#{self.fill_style_type}' name='#{fill_style_type_txt}' />"
    end
  end
  
  private
    def fill_style_type_txt
      return case self.fill_style_type
      when 0
        "solid fill"
      when '10'.to_i(16)
        "linear gradient fill"
      when '12'.to_i(16)
        "radial gradient fill"
      when '13'.to_i(16)
        "focal radial gradient fill (not implemented)"
      when '40'.to_i(16)
        "repeating bitmap fill (no bitmap data)"
      when '41'.to_i(16)
        "clipped bitmap fill (no bitmap data)"
       when '42'.to_i(16)
        'non-smoothed repeating bitmap fill (no bitmap data)'
       when '43'.to_i(16)
        'non-smoothed clipped bitmap fill (no bitmap data)'
      else
        "unknown fill style"
      end
    end
end