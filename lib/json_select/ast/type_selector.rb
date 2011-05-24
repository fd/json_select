module JSONSelect::Ast::TypeSelector

  # `object` | `array` | `number` | `string` | `boolean` | `null`
  def to_ast
    { :f => :instance_of_type, :n => self.text_value }
  end

end
