require 'bundler'
Bundler::GemHelper.install_tasks

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new do |t|
  t.pattern   = "./spec/**/*_spec.rb"
  t.rspec_opts = [
    '--color',
    '-r', File.expand_path("../spec/spec_helper.rb", __FILE__)]
end

task :checkout_conformance_tests do
  sh "git submodule init"
  sh "git submodule update"
end

task :build_parser do
  sh "bundle exec tt lib/json_select/selector_parser.tt -o lib/json_select/selector_parser.rb"

  path = 'lib/json_select/selector_parser.rb'
  src = File.read(path)
  src.gsub!('JSONSelectSelector', 'JSONSelect::Selector')
  File.open(path, 'w+') { |f| f.write src }
end

task :build do
  h = Bundler::GemHelper.instance
  path = Dir[File.join(h.base, "pkg", "#{h.gemspec.name}-*.gem")].sort_by{|f| File.mtime(f)}.last
  sh "gem sign #{path}"
end

task :spec    => [:checkout_conformance_tests, :build_parser]
task :build   => :build_parser
task :default => :spec
