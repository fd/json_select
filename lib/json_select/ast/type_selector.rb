module JSONSelect::Ast::TypeSelector
  
  # `object` | `array` | `number` | `string` | `boolean` | `null`
  def to_ast
    { "type" => self.text_value }
  end
  
end
