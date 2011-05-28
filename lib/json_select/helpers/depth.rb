module JSONSelect::DepthHelpers

  def is_root(object, test, key, idx, size, depth)
    depth == 0
  end

  def format_is_root(test)
    ":root"
  end

end
