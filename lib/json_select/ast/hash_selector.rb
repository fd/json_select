module JSONSelect::Ast::HashSelector

  def to_ast
    tv = self.text_value[1..-1]
    if tv[0,1] == '"'
      { :f => :has_class, :n => eval(tv) }
    else
      { :f => :has_class, :n => tv }
    end
  end

end
