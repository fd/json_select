module JSONSelect::Ast::SimpleExpr
  
  def to_ast
    { 'a' => 0, 'b' => text_value.to_i }
  end
  
end
