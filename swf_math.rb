class SwfMath
  def self.parse_signed_int( bitstring ) 
      remainder = bitstring.slice(1,bitstring.size)
      negative = (bitstring[0] == '1'[0])
      if negative
        # ben's crazy signed integer computation
        temp_val = remainder.gsub('0','t').gsub('1','0').gsub('t','1').to_i(2)
        -1*temp_val - 1
      else
        remainder.to_i(2)
      end
  end
  
  def self.parse_signed_float( bitstring )
    bs = bitstring.reverse
    decimal16 = bs.slice(0,16).reverse
    
    number = 0
    #puts("#{decimal16}")
    val = 0.5
    decimal16.size.times do |i|
      number = number + decimal16.to_i[i]*val
      val = val*0.5
    end
    if (bitstring.size > 16)
      integer16 = bs.slice(16,16).reverse.to_i(2)
    else
      integer16 = 0
    end
    #puts integer16
    number = number + integer16
    #return number
  end
end