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

  def to_s
    selectors = @ast
    selectors = (selectors[0] == ',' ? selectors[1..-1] : [selectors])

    selectors.map do |selector|
      selector.map do |part|
        case part

        when :>
          '>'

        when Hash
          tests = (part[:tests].empty? ? ['*'] : part[:tests])

          tests.map do |test|
            case test

            when '*'
              '*'

            when Hash
              @helpers.send("format_#{test[:f]}", test)

            end
          end.join('')

        end

      end.join(' ')
    end.join(', ')
  end

  def inspect
    "#<JSONSelect (#{to_s})>"
  end

private

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

        object.each do |key, child|
          _each(a1, child, key, nil, nil, depth + 1, &block)
        end

      else
        if object.respond_to?(:json_select_each)
          children = []
          object.json_select_each do |value|
            children << value
          end

          a1.unshift(',')
          size = children.size

          children.each_with_index do |child, idx|
            _each(a1, child, nil, idx, size, depth + 1, &block)
          end

        elsif object.respond_to?(:json_select_each_pair)
          a1.unshift(',')

          object.json_select_each_pair do |key, child|
            _each(a1, child, key, nil, nil, depth + 1, &block)
          end

        end
      end
    end

    if call and block
      block.call(object)
    end
  end

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
