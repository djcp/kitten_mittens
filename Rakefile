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

def with_interrupt_trapping_for(km)
  begin
    yield
  rescue SystemExit, Interrupt
    km.db.close
    puts 'Exiting'
    exit
  end
end

desc 'Take pictures 5 seconds apart'
task :watch do
  km = KittenMittens.new

  with_interrupt_trapping_for(km) do
    while true do
      km.snap
      print '.'
      sleep 5
    end
  end
end

desc 'Watch, analyze and remove'
task :watch_and_analyze_all do
  km = KittenMittens.new

  with_interrupt_trapping_for(km) do
    count = 0
    while true do
      count = count + 1
      km.snap
      print '.'
      if count % 50 == 0
        km.analyze_all
        km.remove_similar_images
      else
        sleep 5
      end
    end
  end
end

desc 'Analyze for motion'
task :analyze_all do
  km = KittenMittens.new
  km.analyze_all
end

desc 'Remove similar images'
task :remove_similar_images do
  km = KittenMittens.new
  km.remove_similar_images
end

desc 'Reset state'
task :reset do
  km = KittenMittens.new
  km.reset
end
