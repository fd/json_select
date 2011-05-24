module JSONSelect::Ast::CombinationSelector

  def to_ast
    ast = [a.to_ast]

    b.elements.each do |comb|
      ast.push(:>) if comb.c.text_value.strip == '>'
      ast.push(comb.d.to_ast)
    end

    ast
  end

end