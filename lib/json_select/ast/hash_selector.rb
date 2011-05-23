module JSONSelect::Ast::HashSelector

  def to_ast
    tv = self.text_value[1..-1]
    if tv[0,1] == '"'
      { "class" => eval(tv) }
    else
      { "class" => tv }
    end
  end
  
end
