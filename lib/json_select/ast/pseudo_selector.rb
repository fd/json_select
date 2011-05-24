module JSONSelect::Ast::PseudoSelector

  def to_ast
    if respond_to?(:e)
      ast = { :pseudo_function => a.text_value, :a => 0 , :b => 0 }
      ast.merge!(e.to_ast)
      ast
    else
      case a.text_value

      when 'first-child'
        { :pseudo_function => 'nth-child', :a => 0, :b => 1 }

      when 'last-child'
        { :pseudo_function => 'nth-last-child', :a => 0, :b => 1 }

      else
        { :pseudo_class => a.text_value }

      end
    end
  end

end
