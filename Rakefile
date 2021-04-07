# A Rakefile defines tasks to help maintain your project.
# Rake provides several task templates that are useful.

# This task template will make a task named 'test', and run
# the tests that it finds.
require "rake/testtask"

namespace(:test) do
  #------------------------------------------------------------------#
  #                    Code Style Tasks
  #------------------------------------------------------------------#
  require "chefstyle"
  require "rubocop/rake_task"
  RuboCop::RakeTask.new(:lint)

  #------------------------------------------------------------------#
  #                    Test Runner Tasks
  #------------------------------------------------------------------#
  Rake::TestTask.new(:unit) do |t|
    t.libs.push "lib"
    t.test_files = FileList["test/unit/*_test.rb"]
  end

  def windows?
    RUBY_PLATFORM =~ /cygwin|mswin|mingw/
  end

  def mac_os?
    RUBY_PLATFORM =~ /darwin/
  end

  namespace(:int) do
    Rake::TestTask.new(:actual_tests) do |t|
      t.libs.push "lib"
      t.test_files = FileList["test/integration/*_test.rb"]
    end
  end
end

task test: %i{test:unit}

task default: %i{test:lint test:unit}
