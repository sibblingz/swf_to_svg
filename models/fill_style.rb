class FillStyle
  attr_accessor :fill_style_type, :color
  
  def to_txt
    what_fill_style
    path ="FILL STYLE :: #{fill_style_type_txt} (#{fill_style_type}) -> color (#{color.r}, #{color.g}, #{color.b})"
  end
  
  def to_xml
"<fill_style type='#{self.fill_style_type}' name='#{fill_style_type_txt}'>
  #{color.to_xml}
</fill_style>"
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
        "focial radial gradient fill"
      when '40'.to_i(16)
        "repeating bitmap fill"
      when '41'.to_i(16)
        "clipped bitmap fill"
       when '42'.to_i(16)
        'non-smoothed repeating bitmap fill'
       when '43'.to_i(16)
        'non-smoothed clipped bitmap fill'
      else
        "unknown fill style"
      end
    end
end