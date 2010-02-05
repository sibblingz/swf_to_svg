class FillStyle
  attr_accessor :fill_style_type, :color
  attr_reader :fill_style_type_txt
  
  def to_txt
    what_fill_style
    path ="FILL STYLE :: #{fill_style_type_txt} (#{fill_style_type}) -> color (#{color.r}, #{color.g}, #{color.b})"
  end
  
  private
    def what_fill_style
      case @fill_style_type
      when 0
        @fill_style_type_txt = "solid fill"
      when '10'.to_i(16)
        @fill_style_type_txt = "linear gradient fill"
      when '12'.to_i(16)
        @fill_style_type_txt = "radial gradient fill"
      when '13'.to_i(16)
        @fill_style_type_txt = "focial radial gradient fill"
      when '40'.to_i(16)
        @fill_style_type_txt = "repeating bitmap fill"
      when '41'.to_i(16)
        @fill_style_type_txt = "clipped bitmap fill"
       when '42'.to_i(16)
        @fill_style_type_txt = 'non-smoothed repeating bitmap fill'
       when '43'.to_i(16)
        @fill_style_type_txt = 'non-smoothed clipped bitmap fill'
      else
        @fill_style_type_txt = "unknown fill style"
      end
    end
end