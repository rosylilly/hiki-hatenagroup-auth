require 'rake/testtask'

task :default => :test

namespace :test do
  Rake::TestTask.new(:sample) do | t |
    t.ruby_opts << '-r test/unit'
    t.test_files = ['test/test_sample.rb']
  end

  Rake::TestTask.new(:all) do | t |
    t.ruby_opts << '-r test/unit'
    t.test_files = FileList['test/test_*.rb']
  end
end

desc 'Run tests'
task :test => ['test:all']
