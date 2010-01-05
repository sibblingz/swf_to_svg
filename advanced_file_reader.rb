class AdvancedFileReader
  
  attr_accessor :file_stream, :current_byte, :bit_string, :next_read_position, :debug
  
  def total_bytes_read=(value)
    @total_bytes_read = value
  end
  
  def total_bytes_read
    @total_bytes_read ||= 0
    return @total_bytes_read
  end
  
  def initialize( file_stream )
    self.file_stream = file_stream
  end
  
  def to_bit_string( int_val )
    temp = int_val.to_s(2)
    if temp.size < 8
      prefix = ''
      (8-temp.size).times do
        prefix += '0'
      end
      temp = prefix + temp
    end
    return temp
  end
  
  def getc
    if next_read_position == 0 
      self.next_read_position = 8
      return current_byte
    end
    self.current_byte = file_stream.getc
    self.total_bytes_read += 1
    self.bit_string = to_bit_string(self.current_byte)
    self.next_read_position = 8
    
    return self.current_byte
  end
  
  def next_n_bits( num_bits )
    return_value = ''
    while return_value.size < num_bits
      if self.debug
        puts "Bit String: #{self.bit_string}"
        puts "Next Read Position: #{next_read_position}"
      end
        
      bits_remaining = num_bits - return_value.size
      bits_left_in_byte = 8 - self.next_read_position
      if bits_remaining > bits_left_in_byte
        return_value += bit_string.slice( self.next_read_position, bits_left_in_byte )
        self.next_read_position = 0
        self.current_byte = file_stream.getc
        self.total_bytes_read += 1
        self.bit_string = to_bit_string( self.current_byte )
      else
        return_value += bit_string.slice( self.next_read_position, bits_remaining )
        self.next_read_position += bits_remaining
      end
    end
    puts "return value: #{return_value}" if self.debug
    return_value
  end
  
  def eof?
    file_stream.eof?
  end
  
  def skip_to_next_byte
    puts "Skipping to next byte! current read position: #{next_read_position}"
    self.next_read_position = 8
  end
  
  def close
    self.file_stream.close
  end
  
end