# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever

# Default interval
# To actually set the default interval, use cron_interval in your application config
require 'active_support/all'

@interval ||= 1

this_gem_path = File.expand_path('../..', __FILE__)
set :path, this_gem_path
set :output, "#{this_gem_path}/log/cron.log"

job_type :ruby_script,  'cd :path && bundle exec ruby bin/:task :output'

every @interval.to_i.minute do
  ruby_script 'internet_box_logger'
end
