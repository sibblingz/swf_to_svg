class AdvancedFileReader
  
  attr_accessor :file_stream, :buffer, :total_bytes_read
  
  def initialize( file_stream )
    @file_stream = file_stream
    @buffer = ''
    @total_bytes_read = 0
  end
  
  def getc()
    ret_val = next_n_bits( 8 ).to_i(2)
    return ret_val
  end
  
  def get_u8()
    skip_to_next_byte
    u8 = getc
  end
  
  def get_u16()
    skip_to_next_byte
    byte1 = getc
    byte2 = getc
    #puts "byte1: #{byte1}"
    #puts "byte2: #{byte2}"
    u16 = byte1 + 256*byte2
    #@total_bytes_read = @total_bytes_read + 2
  end
  
  def get_u32()
    skip_to_next_byte
    byte1 = getc
    byte2 = getc
    byte3 = getc
    byte4 = getc

    u32 = (byte1 + 256*byte2 + 65536*byte3 + 16777216*byte4)
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
    raise "Skipping more than a byte (#{buffer.size}) or buffer is nonzero (#{buffer}). " unless (@buffer.size < 8 && @buffer.to_i(2)  == 0)
    #puts "Skipping to next byte.  Buffer size: #{buffer.size} #{buffer}"
    @buffer = ''
  end
  
  def close
    self.file_stream.close
  end
  
end