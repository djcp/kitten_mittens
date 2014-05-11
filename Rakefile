# encoding: utf-8

require 'rubygems'
require 'bundler'
require 'rake'
require './lib/kitten_mittens'

begin
  Bundler.setup(:default)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end

task :default => :run

desc 'Take a snap'
task :snap do
  km = KittenMittens.new
  km.snap
end

desc 'Analyze for motion'
task :analyze do
  km = KittenMittens.new
  km.analyze_all
end
