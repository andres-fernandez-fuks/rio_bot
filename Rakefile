require 'bundler/setup'
require 'English'

task :version do
  require './lib/version'
  puts Version.current
  exit 0
end

require 'cucumber/rake/task'
Cucumber::Rake::Task.new(:acceptance) do |task|
  task.cucumber_opts = ['features', '--tags \'not @wip and not @local\'', '--format pretty', '--format html -o reports/cucumber.html']
end

task :all do
  ['rubocop', 'rake spec', 'rake cucumber'].each do |cmd|
    puts "Starting to run #{cmd}..."
    system("export DISPLAY=:99.0 && bundle exec #{cmd}")
    raise "#{cmd} failed!" unless $CHILD_STATUS.exitstatus.zero?
  end
end

task :build_server do
  ['rake spec_report', 'rake cucumber_report'].each do |cmd|
    puts "Starting to run #{cmd}..."
    system("export DISPLAY=:99.0 && bundle exec #{cmd}")
    raise "#{cmd} failed!" unless $CHILD_STATUS.exitstatus.zero?
  end
end

require 'cucumber/rake/task'
Cucumber::Rake::Task.new(:cucumber) do |task|
  task.cucumber_opts = ['features', '--tags \'not @wip\'']
end

Cucumber::Rake::Task.new(:cucumber_report) do |task|
  task.cucumber_opts = ['features', '--format html -o reports/cucumber.html']
end

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |t|
  t.pattern = './spec/**/*_spec.rb'
end

RSpec::Core::RakeTask.new(:spec_report) do |t|
  t.pattern = './spec/**/*_spec.rb'
  t.rspec_opts = %w[--format RspecJunitFormatter --out reports/spec/spec.xml]
end

task default: [:all]
