describe "JSONSelect", "conformance" do

  p_levels = "../fixtures/conformance/level_*"
  p_groups = "{basic}.json"

  levels = {}

  d = Dir[File.expand_path(p_levels, __FILE__)]
  d.each do |dir|
    level = (levels[File.basename(dir)] = {})

    d = Dir[File.expand_path(p_groups, dir)]
    d.each do |json|
      gname = File.basename(json, '.json')
      group = (level[gname] = {})
      group[:json] = json

      d = Dir[File.expand_path("../#{gname}_*.selector", json)]
      d.each do |selector|
        name = File.basename(selector, '.selector').split('_', 2).last

        group[name] = [selector,
          File.expand_path("../#{gname}_#{name}.output", selector)]
      end
    end
  end

  levels.each do |level, groups|
    describe "(#{level})" do
      groups.each do |group, tests|
        describe "(#{group})" do
          input_p = tests.delete(:json)

          let(:input) do
            Yajl::Parser.parse(File.read(input_p))
          end

          tests.each do |test, (selector_p, output_p)|
            describe "(#{test})" do

              let(:selector) do
                File.read(selector_p)
              end

              let(:output) do
                o = File.read(output_p)
                o.sub! /^172$/, "172\n\"ignored object\""

                e = []
                Yajl::Parser.parse(o) { |o| e << o }
                e
              end

              it "finds all matching children" do
                JSONSelect(selector).matches(input).should == output
              end

              it "finds the first matching child" do
                JSONSelect(selector).match(input).should == output.first
              end

              it "can correctly test the object" do
                JSONSelect(selector).test(input).should be_true
              end

            end
          end
        end
      end
    end
  end

  # %w( basic ).each do |test|
  #   selectors = "../fixtures/#{test}_*.selector"
  #   selectors = Dir[File.expand_path(selectors, __FILE__)]
  #
  #   describe "(#{test})" do
  #
  #     let(:input) do
  #       path = File.expand_path("../fixtures/#{test}.json", __FILE__)
  #       Yajl::Parser.parse(File.read(path))
  #     end
  #
  #     selectors.each do |selector|
  #       basename = File.basename(selector, '.selector')
  #       name     = basename[(test.size + 1)..-1]
  #       output   = File.expand_path("../fixtures/#{basename}.output", __FILE__)
  #       # ast      = File.expand_path("../fixtures/#{basename}.ast", __FILE__)
  #       selector_o = File.expand_path("../fixtures/#{basename}.selector.out", __FILE__)
  #
  #       describe "(#{name})" do
  #
  #         # it "parses the selector" do
  #         #   ast = Yajl::Parser.parse(File.read(ast))
  #         #   s = JSONSelect(File.read(selector).strip)
  #         #   s.should be_a(JSONSelect)
  #         #   Yajl::Parser.parse(Yajl::Encoder.encode(s.ast)).should == ast
  #         # end
  #
  #         # it "produces the correct selector" do
  #         #   s = JSONSelect(File.read(selector).strip)
  #         #   e = File.read(selector_o)
  #         #   s.to_s.should == e
  #         # end
  #
  #       end
  #     end
  #
  #   end
  # end
end