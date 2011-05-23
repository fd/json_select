module JSONSelect::Ast::SelectorGroup
  
  def to_ast
    if b.elements.empty?
      return a.to_ast
    end
    
    ast = [',', a.to_ast]
    
    b.elements.each do |group|
      ast.push group.c.to_ast
    end
    
    ast
  end
  
end
