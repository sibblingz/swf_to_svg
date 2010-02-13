class SymbolClassTag
  attr_accessor :num_symbols, :tag_ids, :tag_names
  
  def to_xml
    "<symbols num='#{num_symbols}'>
      #{tags_to_xml}
     </symbols>"
  end
  private
    def tags_to_xml
      return_val = tag_ids.each_with_index.map{ |id, i| "<symbol tag_id='#{id}' name='#{tag_names[i]}'/>" }.join("\n")
    end
end