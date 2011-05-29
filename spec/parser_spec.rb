describe "JSONSelect", "parser" do

  p_levels = "../fixtures/parser/level_*"
  p_groups = %w( basic )

  levels = {}

  d = Dir[File.expand_path(p_levels, __FILE__)]
  d.each do |dir|
    level = (levels[File.basename(dir)] = {})

    p_groups.each do |gname|
      json  = File.expand_path(gname, dir)
      group = (level[gname] = {})

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
          tests.each do |test, (selector_p, output_p)|
            describe "(#{test})" do

              let(:selector) do
                File.read(selector_p)
              end

              let(:output) do
                File.read(output_p)
              end

              it "produces the correct selector" do
                JSONSelect(selector).to_s.should == output
              end

            end
          end
        end
      end
    end
  end

end