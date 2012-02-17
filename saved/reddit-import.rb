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
class User < ActiveRecord::Base
end
class Subreddit < ActiveRecord::Base
end

def login(user,password)
  agent = Mechanize.new
  agent.get('http://reddit.com') do |login_page|
      inside_page = login_page.form_with(:id => 'login_login-main') do |f|
          f.user = user
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
  method_option :user, :type => :string, :aliases => "-u", :required => true
  def import
    puts "#{Post.count} records found"
    agent = login(options['user'],options['password'])
    after = ""
    last = ""
    user = User.find_or_create_by_name(options['user'])
    puts "User: #{user.name}"
    while true do
      page = agent.get("http://reddit.com/saved.json#{after}")

      page = JSON.parse(page.content)
      page['data']['children'].each do |link|
        data = link['data']
        data['user_id'] = user.id
        data['subreddit_id'] = Subreddit.find_or_create_by_name(data['subreddit']).id
        puts data['subreddit_id']
        old_post = nil
        if !options['duplicate'] then
          old_post = Post.where(:user_id => user.id,:name => data['name'],
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
          puts "#{Post.count} | Creating: #{post.url}|#{post.user_id}"
        end
        # pp post.url # add back with verbose option?
      end
      if page['data']['after'].nil? then 
        break 
      end
      last = page['data']['after']
      after = "?after=#{last}"
      sleep(5)
    end
  end

  desc "list", "output stored links"
  method_option :users, :type => :string, :aliases => "-u"
  method_option :subreddits, :type => :string, :aliases => "-s"
  method_option :urls, :type => :boolean, :aliases => "-l", :default => true
  method_option :subreddits, :type => :string, :aliases => "-s"
  method_option :authors, :type => :string, :aliases => "-a"
  method_option :domains, :type => :string, :aliases => "-d"
  method_option :nsfw, :type => :boolean
  method_option :perma, :type => :boolean, :aliases => "-c", :default => false
  def list
    all_users = options['users'].nil?
    all_subreddits = options['subreddits'].nil?
    search = {}
    names = options['users'].split(" ")
    users = User.where(:name => names).map { |u| u.id }
    posts = Post.where(:user_id => users)
    posts.each { |post| puts post.url }
  end
end
# Create task that accesses an already created database and
# exports information

# Options: 
# JSON (could warn about memory usage)
# HTML verbose or short
# Bookmarks format
# Filter by score,comments
# Create only one file or multiple?
# Delete by filter or delete all but filter

App.start
