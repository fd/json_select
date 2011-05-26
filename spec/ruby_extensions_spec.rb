describe "JSONSelect", "Ruby extensions" do
  
  it "treats Symbol keys as Strings" do
    JSONSelect('.name .first').
      match(:name => { :first => 'hello' }).
      should == 'hello'
  end
  
  it "treats Symbol values as Strings" do
    JSONSelect('.name string.uid').
      match(:name => { :uid => :hello }).
      should == :hello
  end
  
  it "treats Objects which respond to #json_select_each_pair as Objects" do
    class Person < Struct.new(:name, :age)
      def json_select_each_pair
        yield(:name, self.name)
        yield(:age, self.age)
      end
    end
    
    JSONSelect('object.person string.name').
      match(:person => Person.new('Simon Menke', 24)).
      should == 'Simon Menke'
  end
  
  it "treats Objects which respond to #json_select_each as Arrays" do
    class List
      def initialize(items)
        @items = items
      end
      
      def json_select_each
        @items.each { |i| yield(i) }
      end
    end
    
    JSONSelect('array.person string:first-child').
      match(:person => List.new(%w( foo bar baz ))).
      should == 'foo'
  end
  
end