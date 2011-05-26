module JSONSelect::PositionHelpers
  
  def nth_child(object, test, key, idx, size, depth)
    return false unless idx
    
    idx += 1
    
    a = test[:a]
    b = test[:b]
    
    if a == 0
      (b == idx)
    else
      (((idx - b) % a) == 0) and ((idx * a + b) >= 0)
    end
  end
  
  def nth_last_child(object, test, key, idx, size, depth)
    nth_child(object, test, key, (size - idx) - 1, size, depth)
  end
  
end
