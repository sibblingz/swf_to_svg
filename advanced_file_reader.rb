class AdvancedFileReader
  
  attr_accessor :file_stream, :buffer, :total_bytes_read
  attr_reader :is_compressed
  
  def initialize( file_stream )
    @file_stream = file_stream
    @buffer = ''
    @total_bytes_read = 0
    @is_compressed = false
  end
  
  def getc()
    ret_val = next_n_bits( 8 ).to_i(2)
    return ret_val
  end
  
  def get_u8()
    skip_to_next_byte
    u8 = getc
    #skip_to_next_byte
    return u8
  end
  
  def get_u16()
    skip_to_next_byte
    byte1 = getc
    byte2 = getc
    #puts "byte1: #{byte1}"
    #puts "byte2: #{byte2}"
    u16 = byte1 + 256*byte2
    #skip_to_next_byte
    #@total_bytes_read = @total_bytes_read + 2
    return u16
  end
  
  def get_u32()
    skip_to_next_byte
    byte1 = getc
    byte2 = getc
    byte3 = getc
    byte4 = getc

    u32 = (byte1 + 256*byte2 + 65536*byte3 + 16777216*byte4)
    #skip_to_next_byte
    return u32
  end
  
  def get_si( num_bits )
    return parse_signed_int( self.next_n_bits(num_bits) )
  end
  
  def get_fp( num_bits )
    return parse_fixed_point( self.next_n_bits(num_bits) ) 
  end
  
  def next_n_bits( num_bits )
    while @buffer.size < num_bits
      @buffer += @file_stream.getc.chr.unpack("B8")[0]
      @total_bytes_read = @total_bytes_read + 1
    end
    #puts "#{buffer}"
    @buffer.slice!(0, num_bits)
  end
  
  def eof?
    @file_stream.eof?
  end
  
  def skip_to_next_byte
    raise "Skipping more than a byte (#{buffer.size}) or buffer is nonzero (#{buffer}). Bytes read so far: #{total_bytes_read}" unless (@buffer.size < 8 && @buffer.to_i(2)  == 0)
    #puts "Skipping to next byte.  Buffer size: #{buffer.size} #{buffer}"
    @buffer = ''
  end
  
  def decompress
    @is_compressed = true
    puts "Decompressing in the silliest way possible!"
    buf = Zlib::Inflate.inflate( @file_stream.read )
    
    g = File.open("tmp", "w")
    g.write("#{buf}")
    g.close
    
    g = File.open( "tmp" , "r")
    @file_stream = g
  end
  
  def close
    if(@is_compressed)
      system("rm tmp")
    end
    self.file_stream.close
  end
  
  def get_tag
    skip_to_next_byte # manual byte alignment here
    tag_1 = next_n_bits( 8 )
    tag_2 = next_n_bits( 8 )
    tag_bit_string = tag_2 + tag_1

    #puts "#{tag_bit_string}"

    tag_code = tag_bit_string.slice(0,10).to_i(2)
    tag_length = tag_bit_string.slice(10,6).to_i(2)

    if tag_length >= 63
      #puts "long tag!"
      # tag_length_1 = f.getc
      # tag_length_2 = f.getc
      # tag_length_3 = f.getc
      # tag_length_4 = f.getc
      #sign = f.next_n_bits( 1 )
      # this should be signed.
      tag_length = get_u32 #tag_length_1 + 256*tag_length_2 + 65536*tag_length_3 + 16777216*tag_length_4
    end

    return [tag_code, tag_length]
  end
  
   
  
  def get_string
    string = ''
    bytes_read = 0
    while true
      next_char = get_u8
      bytes_read += 1

      break if next_char == 0
      string += next_char.chr
    end

    return string, bytes_read
  end
  
  private
   def parse_signed_int( bitstring ) 
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

    def parse_fixed_point( bitstring )
      num = parse_signed_int( bitstring )
      return num / 65536.0
      
    end
  
end