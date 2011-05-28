module JSONSelect::KeyHelpers

  def has_class(object, test, key, idx, size, depth)
    test[:n] == key.to_s
  end

  def format_has_class(test)
    ".#{test[:n]}"
  end

end
