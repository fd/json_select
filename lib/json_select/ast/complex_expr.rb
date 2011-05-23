module JSONSelect::Ast::ComplexExpr
  
  def to_ast
    _a = ""
    
    if a.text_value.size > 0
      _a += a.text_value
    else
      _a += '+'
    end
    
    if b.text_value.size > 0
      _a += b.text_value
    else
      _a += '1'
    end
    
    if c.text_value.size > 0
      _b = c.text_value.to_i
    else
      _b = 0
    end
    
    { 'a' => _a.to_i, 'b' => _b }
  end
  
end
