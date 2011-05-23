module JSONSelect::Ast::SimpleSelector
  
  def to_ast
    ast = {}
    
    if respond_to?(:a) and respond_to?(:b)
      ast.merge! a.to_ast
      
      b.elements.each do |s|
        ast.merge!(s.to_ast)
      end
      
    else
      self.elements.each do |s|
        ast.merge!(s.to_ast)
      end
      
    end
    
    ast
  end
  
end
