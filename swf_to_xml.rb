Dir.glob('models/shape_records/*') do |file|
  require file
end
Dir.glob('models/control_tags/*') do |file|
  require file
end

require 'advanced_file_reader.rb'
require 'tags/tag.rb'
require 'tags/tag_actions.rb'
require 'swf_math.rb'

DICTIONARY = {}

def get_dictionary
  return DICTIONARY
end

def read_a_swf_file( filename, histogram )
  file_stream = File.open(filename, "r")
  f = AdvancedFileReader.new( file_stream )

  before = f.total_bytes_read

  signature_1 = f.get_u8
  signature_2 = f.get_u8
  signature_3 = f.get_u8

  if signature_1 != 'F'[0]
    raise "Please Export an Uncompressed SWF file"
  end

  if signature_2 != 'W'[0]
    raise "Expected second byte to be 'W'"
  end

  if signature_3 != 'S'[0]
    raise "Expected third byte to be 'S'"
  end

  version = f.get_u8

  puts "Flash Version: #{version}"

  num_bytes_total = f.get_u32 

  puts "Num Bytes total: #{num_bytes_total}"

  frame = Rect.new(f)

  puts "Frame Size: #{frame.xmax/20} x #{frame.ymax/20}"

  frame_rate_1 = f.get_u8
  frame_rate_2 = f.get_u8
  frame_rate = 0.1*frame_rate_1 + frame_rate_2
  puts "Frame Rate: #{frame_rate}"

  #frame_count_1 = f.getc
  #frame_count_2 = f.getc

  frame_count = f.get_u16#frame_count_1 + 256*frame_count_2
  puts "Frame Count: #{frame_count}"

  new_file_name = filename.chomp(".swf").split("/",2)
  new_file_name = new_file_name[ new_file_name.length - 1]

  output = File.open("output/#{new_file_name}.xml", "w")
  output.write("<?xml version='1.0'?>")
  output.write("<tags>")
  while !f.eof?
    puts "  BEGIN TAG"
    tag_code, tag_length = get_tag(f)
  
    puts "tag_len: #{tag_length}, tag code: #{tag_code}"
    
    tag = Tag.new(tag_code, tag_length, f)
    
    # keep track of the number of the types of tags we have
    if(histogram[tag.tag_string])
      histogram[tag.tag_string] = histogram[tag.tag_string] + 1
    else
      histogram[tag.tag_string] = 1
    end
    #tag.tag_code = tag_code
    #tag.tag_length = tag_length
    output.write tag.to_xml
    #handle_tag( tag_code, tag_length, f )
    #f.skip_to_next_byte
    puts "  END TAG"
    puts ""
  end
  output.write("</tags>")
  after = f.total_bytes_read
  puts "READ: #{after - before} LEN #{num_bytes_total}"
  f.close
  output.close

  # d = get_dictionary
  # d.each do |key, value|
  #   puts "Key: #{key}"

  #   if value.is_a? Shape
  #     output = File.open("output/#{key}.svg", "w")
  #     output.write value.to_svg
  #     output.close
  #   end
  # end
  return histogram
end

#puts "#{ARGV.length}"
#puts "HELLO!" unless ARGV.length != 1

# if File.ARGV[0].exists?
#   read_a_swf_file( ARGV[0] )
# end

tag_histogram = {}
ARGV.length.times do |i|
  puts ""
  puts "------- READING FILE #{ARGV[i]} ------"
  tag_histogram = read_a_swf_file( ARGV[i], tag_histogram )
  puts "-------- END FILE #{ARGV[i]} ---------"
  puts""
end

histogram = File.open("histogram.txt", "w")
tag_histogram.each_pair{ |k,v| histogram.write("#{k}: #{v}\n")}
histogram.close
  
