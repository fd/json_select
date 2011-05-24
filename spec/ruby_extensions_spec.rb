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
  
  it "treats Objects which respond to #json_select_each as Objects" do
    class Person < Struct.new(:name, :age)
      def json_select_each
        yield(:name, self.name)
        yield(:age, self.age)
      end
    end
    
    JSONSelect('object.person string.name').
      match(:person => Person.new('Simon Menke', 24)).
      should == 'Simon Menke'
  end
  
end