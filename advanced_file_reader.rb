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
  
  def next_n_bits( num_bits )
    while @buffer.size < num_bits
      @buffer += @file_stream.getc.chr.unpack("B8")[0]
      @total_bytes_read = @total_bytes_read + 1
    end
    
    @buffer.slice!(0, num_bits)
  end
  
  def eof?
    @file_stream.eof?
  end
  
  def skip_to_next_byte
    raise "You are probably making a mistake" unless @buffer.size < 8
    puts "Skipping to next byte.  Buffer size: #{buffer.size}"
    @buffer = ''
  end
  
  def close
    self.file_stream.close
  end
  
end