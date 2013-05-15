require 'rubygems'
require 'bundler/setup'
require 'daemons'

Daemons.run('feed_buzzer_worker.rb', {:log_output => true})
