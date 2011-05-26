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
          raise JSONSelect::ParseError, parser.failure_reason
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
    
    @helpers = Module.new
    @helpers.send(:extend,
      JSONSelect::KeyHelpers,
      JSONSelect::TypeHelpers,
      JSONSelect::SizeHelpers,
      JSONSelect::DepthHelpers,
      JSONSelect::PositionHelpers)
    
    @helper_methods = {}
    (@helpers.public_methods - Module.public_methods).map do |name|
      @helper_methods[name.to_sym] = @helpers.method(name)
    end
  end

  # Returns the first matching child in `object`
  def match(object)
    _each(@ast, object, nil, nil, nil, 0) do |object|
      return object
    end

    return nil
  end

  alias_method :=~, :match

  # Returns all matching children in `object`
  def matches(object)
    matches = []

    _each(@ast, object, nil, nil, nil, 0) do |object|
      matches << object
    end

    matches
  end

  # Returns true if `object` has any matching children.
  def test(object)
    _each(@ast, object, nil, nil, nil, 0) do |object|
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
  def _each(selector, object, id, number, total, depth, &block)
    a0 = (selector[0] == ',' ? selector[1..-1] : [selector])
    a1 = []

    call = false

    a0.each do |selector|
      ok, extra = _match(object, selector, id, number, total, depth)

      call = true if ok
      a1.concat extra
    end

    if a1.any?
      case object

      when Array
        a1.unshift(',')
        size = object.size

        object.each_with_index do |child, idx|
          _each(a1, child, nil, idx, size, depth + 1, &block)
        end

      when Hash
        a1.unshift(',')
        size = object.size

        object.each_with_index do |(key, child), idx|
          _each(a1, child, key, idx, size, depth + 1, &block)
        end

      else
        if object.respond_to?(:json_select_each)
          children = []
          object.json_select_each do |key, value|
            children << [key, value]
          end
          
          a1.unshift(',')
          size = children.size
          
          children.each_with_index do |(key, child), idx|
            _each(a1, child, key, idx, size, depth + 1, &block)
          end
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
  def _match(object, selector, id, number, total, depth)
    selectors = []
    current_selector = (selector[0] == :> ? selector[1] : selector[0])
    match = true
    has_root_test = false

    current_selector[:tests].each do |test|
      if test[:f] == :is_root
        has_root_test = true
      end
      
      if match
        match = !!@helper_methods[test[:f].to_sym].call(object, test, id, number, total, depth)
      end
    end

    # continue search for decendants
    if Hash === selector[0] and !has_root_test
      selectors.push selector
    end

    # break search for terminals
    if selector.size <= 1
      return [match, selectors]
    end

    # break search (no match)
    unless match
      return [match, selectors]
    end
    
    # continue search for decendants
    unless selector[0] == :>
      match = false
      selectors.push selector[1..-1]
      return [match, selectors]
    end
    
    # continue search for children
    if selector.length > 2 
      match = false
      selectors.push selector[2..-1]
    end

    return [match, selectors]
  end

end
