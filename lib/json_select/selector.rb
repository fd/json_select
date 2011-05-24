class JSONSelect

  attr_reader :ast

  @@parser_cache = {}

  def self.reset_cache!
    @@parser_cache.clear
  end

  def initialize(src, use_parser_cache=true)
    case src

    when String
      ast = nil

      if use_parser_cache
        ast = @@parser_cache[src]
      end

      if ast
        @ast = ast

      else
        parser = JSONSelect::SelectorParser.new
        tree   = parser.parse(src)
        unless tree
          raise JSONSelect::ParseError, @parser.failure_reason
        end

        @ast = tree.to_ast

        if use_parser_cache
          @@parser_cache[src] = ast
        end
      end

    when Array
      @ast = src

    else
      raise ArgumentError, "Expected a string for ast"

    end
  end

  # Returns the first matching child in `object`
  def match(object)
    _each(@ast, object, nil, nil, nil) do |object|
      return object
    end

    return nil
  end

  alias_method :=~, :match

  # Returns all matching children in `object`
  def matches(object)
    matches = []

    _each(@ast, object, nil, nil, nil) do |object|
      matches << object
    end

    matches
  end

  # Returns true if `object` has any matching children.
  def test(object)
    _each(@ast, object, nil, nil, nil) do |object|
      return true
    end

    return false
  end

  alias_method :===, :test

private

  # function forEach(sel, obj, fun, id, num, tot) {
  #   var a = (sel[0] === ',') ? sel.slice(1) : [sel];
  #   var a0 = [];
  #   var call = false;
  #   for (var i = 0; i < a.length; i++) {
  #     var x = mn(obj, a[i], id, num, tot);
  #     if (x[0]) call = true;
  #     for (var j = 0; j < x[1].length; j++) a0.push(x[1][j]);
  #   }
  #   if (a0.length && typeof obj === 'object') {
  #     if (a0.length >= 1) a0.unshift(",");
  #     if (isArray(obj)) {
  #       for (var i = 0; i < obj.length; i++) forEach(a0, obj[i], fun, undefined, i, obj.length);
  #     } else {
  #       // it's a shame to do this for :last-child and other
  #       // properties which count from the end when we don't
  #       // even know if they're present.  Also, the stream
  #       // parser is going to be pissed.
  #       var l = 0;
  #       for (var k in obj) if (obj.hasOwnProperty(k)) l++;
  #       var i = 0;
  #       for (var k in obj) if (obj.hasOwnProperty(k)) forEach(a0, obj[k], fun, k, i++, l);
  #     }
  #   }
  #   if (call && fun) fun(obj);
  # };
  def _each(selector, object, id, number, total, &block)
    a0 = (selector[0] == ',' ? selector[1..-1] : [selector])
    a1 = []

    call = false

    a0.each do |selector|
      ok, extra = _match(object, selector, id, number, total)

      call = true if ok
      a1.concat extra
    end

    if a1.any?
      case object

      when Array
        a1.unshift(',')
        size = object.size

        object.each_with_index do |child, idx|
          _each(a1, child, nil, idx, size, &block)
        end

      when Hash
        a1.unshift(',')
        size = object.size

        object.each_with_index do |(key, child), idx|
          _each(a1, child, key, idx, size, &block)
        end

      end
    end

    if call and block
      block.call(object)
    end
  end


  # function mn(node, sel, id, num, tot) {
  #   var sels = [];
  #   var cs = (sel[0] === '>') ? sel[1] : sel[0];
  #   var m = true;
  #   if (cs.type) m = m && (cs.type === mytypeof(node));
  #   if (cs.id)   m = m && (cs.id === id);
  #   if (m && cs.pf) {
  #     if (cs.pf === ":nth-last-child") num = tot - num;
  #     else num++;
  #     if (cs.a === 0) {
  #       m = cs.b === num;
  #     } else {
  #       m = (!((num - cs.b) % cs.a) && ((num*cs.a + cs.b) >= 0));
  #     }
  #   }
  #
  #   // should we repeat this selector for descendants?
  #   if (sel[0] !== '>' && sel[0].pc !== ":root") sels.push(sel);
  #
  #   if (m) {
  #     // is there a fragment that we should pass down?
  #     if (sel[0] === '>') { if (sel.length > 2) { m = false; sels.push(sel.slice(2)); } }
  #     else if (sel.length > 1) { m = false; sels.push(sel.slice(1)); }
  #   }
  #
  #   return [m, sels];
  # }
  def _match(object, selector, id, number, total)
    selectors = []
    current_selector = (selector[0] == :> ? selector[1] : selector[0])
    match = true

    if current_selector.key?(:type)
      match = (match and current_selector[:type] == _type_of(object))
    end

    if current_selector.key?(:class)
      match = (match and current_selector[:class] == id)
    end

    if match and current_selector.key?(:pseudo_function)
      pseudo_function = current_selector[:pseudo_function]

      if pseudo_function == 'nth-last-child'
        number = total - number
      else
        number += 1
      end

      if current_selector[:a] == 0
        match = current_selector[:b] == number
      else
        # WTF!
        match = ((((number - current_selector[:b]) % current_selector[:a]) == 0) && ((number * current_selector[:a] + current_selector[:b]) >= 0))
      end
    end

    if selector[0] != :> and selector[0][:pseudo_class] != 'root'
      selectors.push selector
    end

    if match
      if selector[0] == :>
        if selector.length > 2
          m = false
          selectors.push selector[2..-1]
        end
      elsif selector.length > 1
        m = false
        selectors.push selector[1..-1]
      end
    end

    return [match, selectors]
  end

  def _type_of(object)
    case object
    when Hash       then 'object'
    when Array      then 'array'
    when String     then 'string'
    when Symbol     then 'string'
    when Numeric    then 'number'
    when TrueClass  then 'boolean'
    when FalseClass then 'boolean'
    when NilClass   then 'null'
    else raise "Invalid object of class #{object.class} for JSONSelect: #{object.inspect}"
    end
  end

end
