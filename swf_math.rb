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
  
  def self.parse_fixed_point( bitstring )
    # unless prec == 16 || prec == 8
    #   raise "invalid precision for parsing to float" 
    # end
    prec = 16
    bs = bitstring.reverse
    decimal = bs.slice(0,prec).reverse
    
    number = 0
    #puts("#{decimal16}")
    val = 0.5
    decimal.size.times do |i|
      number = number + decimal.to_i[i]*val
      val = val*0.5
    end
    if (bitstring.size > prec)
      integer = bs.slice(prec,prec).reverse.to_i(2)
    else
      integer = 0
    end
    #puts integer16
    number = number + integer
    #return number
  end
  
  def self.parse_ASCII_string( f )
    # i assume this works, but i'm not sure!
    s = ""
    while true
      char = f.getc
      if(char == 0)
        break
      end
      s = s + char.chr
    end
    puts s
    return s
  end
end