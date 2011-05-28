module JSONSelect::SizeHelpers

  def only_child(object, test, key, idx, size, depth)
    return false unless size

    size == 1
  end

  def format_only_child(test)
    ":only-child"
  end

  def empty(object, test, key, idx, size, depth)
    return false unless size

    case object
    when Array then return object.empty?
    else
      if object.respond_to?(:json_select_each)
        object.json_select_each { return false }
        return true
      end
    end

    return false
  end

  def format_empty(test)
    ":empty"
  end

end
