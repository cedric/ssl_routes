require 'rake/testtask'
require 'lib/ssl_routes/version'

namespace :gem do

  desc 'Run tests.'
  Rake::TestTask.new(:test) do |test|
    test.libs << 'lib' << 'test'
    test.pattern = 'test/**/*_test.rb'
    test.verbose = true
  end

  desc 'Build gem.'
  task :build => :test do
    system "gem build ssl_routes.gemspec"
  end

  desc 'Build, tag and push gem.'
  task :release => :build do
    # tag and push
    system "git tag v#{SslRoutes::VERSION}"
    system "git push origin --tags"
    # push gem
    system "gem push ssl_routes-#{SslRoutes::VERSION}.gem"
  end

end

task :default => 'gem:test'