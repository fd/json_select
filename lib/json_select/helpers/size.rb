module JSONSelect::SizeHelpers
  
  def only_child(object, test, key, idx, size, depth)
    size == 1
  end
  
  def empty(object, test, key, idx, size, depth)
    case object
    when Array then return object.empty?
    when Hash  then return object.empty?
    else
      if object.respond_to?(:json_select_each)
        object.json_select_each { return false }
        return true
      end
    end
    return false
  end
  
end
