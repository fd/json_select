describe "JSONSelect", "conformance" do

  %w( basic ).each do |test|
    selectors = "../fixtures/#{test}_*.selector"
    selectors = Dir[File.expand_path(selectors, __FILE__)]

    describe "(#{test})" do

      let(:input) do
        path = File.expand_path("../fixtures/#{test}.json", __FILE__)
        Yajl::Parser.parse(File.read(path))
      end

      selectors.each do |selector|
        basename = File.basename(selector, '.selector')
        name     = basename[(test.size + 1)..-1]
        output   = File.expand_path("../fixtures/#{basename}.output", __FILE__)
        ast      = File.expand_path("../fixtures/#{basename}.ast", __FILE__)

        describe "(#{name})" do

          it "parses the selector" do
            ast = Yajl::Parser.parse(File.read(ast))
            s = JSONSelect(File.read(selector).strip)
            s.should be_a(JSONSelect::Selector)
            s.ast.should == ast
          end

          it "produces the correct output" do
            s = JSONSelect(File.read(selector).strip)
            e = []
            Yajl::Parser.parse(File.read(output)) { |o| e << o }
            s.match(input).should == e
          end

          it "can correctly test the object" do
            s = JSONSelect(File.read(selector).strip)
            e = []
            Yajl::Parser.parse(File.read(output)) { |o| e << o }
            s.test(input).should be_true
          end

        end
      end

    end
  end
end