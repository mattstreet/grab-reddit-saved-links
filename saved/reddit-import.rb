#!/usr/bin/env ruby
require 'rubygems'
require 'thor'
require 'active_record'
require 'yaml'
require 'mechanize'
require 'json'
require 'pp'

# Add CLI option and default
dbconfig = YAML::load(File.open('config/database.yml'))

# Add CLI and default
ActiveRecord::Base.establish_connection(dbconfig["development"])

# Is this the best way to do this?
class Post < ActiveRecord::Base
end

def login(password)
  agent = Mechanize.new
  agent.get('http://reddit.com') do |login_page|
      inside_page = login_page.form_with(:id => 'login_login-main') do |f|
          f.user = "mattstreet" # Needs CLI option
          f.passwd = password
          f.submit
      end
  end
  return agent
end

class App < Thor

  desc "import", "download saved links"
  method_option :replace, :type => :boolean
  method_option :duplicate, :type => :boolean
  method_option :password, :type => :string, :aliases => "-p", :required => true
  def import
    puts "#{Post.count} records found"
    agent = login(options['password'])
    after = ""
    last = ""
    while true do
      page = agent.get("http://reddit.com/saved.json#{after}")

      page = JSON.parse(page.content)
      page['data']['children'].each do |link|
        data = link['data']
        old_post = nil
        if !options['duplicate'] then
          old_post = Post.where(:name => data['name'],
                                :created_utc => data['created_utc']).first
        end
        data = data.keep_if { |key,value| Post.column_names.include? key }
        if old_post and options['replace']
          old_post.update_attributes(data)
          puts "#{Post.count} | Replacing: #{old_post.url}"
        elsif old_post
          puts "Reached old links"
          exit
        else
          post = Post.create(data)
          puts "#{Post.count} | Creating: #{post.url}"
        end
        # pp post.url # add back with verbose option?
      end
      if page['data']['after'].nil? then 
        puts page['data']['after']
        break 
      end
      last = page['data']['after']
      after = "?after=#{last}"
      pp last
      sleep(5)
    end
  end
end
# Create task that accesses an already created database and
# exports information

# Options: 
# JSON (could warn about memory usage)
# HTML verbose or short
# Bookmarks format
# Filter by subreddits
# Filter by domain
# Filter by author
# Filter by score,comments, over_18
# Create only one file or multiple?
# Delete by filter or delete all but filter

App.start
