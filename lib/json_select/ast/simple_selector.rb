module JSONSelect::Ast::SimpleSelector
  
  def to_ast
    tests = []
    node  = {:tests => tests}
    
    if respond_to?(:a) and respond_to?(:b)
      tests << a.to_ast
      
      b.elements.each do |s|
        tests << s.to_ast
      end
      
    else
      self.elements.each do |s|
        tests << s.to_ast
      end
      
    end
    
    tests.compact!
    
    node
  end
  
end
