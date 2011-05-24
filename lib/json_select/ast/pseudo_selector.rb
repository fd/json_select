module JSONSelect::Ast::PseudoSelector

  def to_ast
    if respond_to?(:e)
      test = { :f => a.text_value.gsub('-', '_') }
      test.merge!(e.to_ast)
      test
    else
      case a.text_value

      when 'first-child'
        { :f => :nth_child, :a => 0, :b => 1 }

      when 'last-child'
        { :f => :nth_last_child, :a => 0, :b => 1 }

      when 'root'
        { :f => :is_root }

      else
        { :f => a.text_value.gsub('-', '_') }

      end
    end
  end

end
