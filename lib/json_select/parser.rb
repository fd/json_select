class JSONSelect::Parser
  
  def initialize(source)
    @parser = JSONSelect::SelectorParserParser.new
    @source = source
  end
  
  def parse
    tree = @parser.parse(@source)
    if tree
      JSONSelect::Selector.new(tree.to_ast)
    else
      raise JSONSelect::ParseError, @parser.failure_reason
      # puts parser.failure_line
      # puts parser.failure_column
    end
  end
  
end
