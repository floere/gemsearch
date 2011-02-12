require 'rubygems'
require 'bundler'
Bundler.require

# Load the "model".
#
require File.expand_path 'gem', File.dirname(__FILE__)

set :haml, { :format => :html5 }

# Sets up two query instances.
#
if ENV['RACK_ENV'] == 'production'
  puts "Running Gemsearch on production"
  FullGems = Picky::Client::Full.new :host => 'gemsearch-server.heroku.com', :port => 80, :path => '/gems/full'
  LiveGems = Picky::Client::Live.new :host => 'gemsearch-server.heroku.com', :port => 80, :path => '/gems/live'
else
  FullGems = Picky::Client::Full.new :host => 'localhost', :port => 8080, :path => '/gems/full'
  LiveGems = Picky::Client::Live.new :host => 'localhost', :port => 8080, :path => '/gems/live'
end

set :static, true
set :public, File.dirname(__FILE__)
set :views,  File.expand_path('views', File.dirname(__FILE__))

# Root, the search interface.
#
get '/' do
  @query = params[:q]
  
  response['Cache-Control'] = 'public, max-age=36000'
  haml :'/search'
end

# Configure. The configuration info page.
#
get '/configure' do
  response['Cache-Control'] = 'public, max-age=36000'
  haml :'/configure'
end

# For full results, you get the ids from the picky server
# and then populate the result with models (rendered, even).
#
get '/search/full' do
  results = FullGems.search params[:query], :offset => params[:offset]
  
  results.extend Picky::Convenience
  results.populate_with AGem do |a_gem|
    a_gem.to_s
  end
  
  response['Cache-Control'] = 'public, max-age=36000'
  ActiveSupport::JSON.encode results
end

# For live results, you'd actually go directly to the search server without taking the detour.
#
get '/search/live' do
  response['Cache-Control'] = 'public, max-age=36000'
  LiveGems.search params[:query], :offset => params[:offset]
end

helpers do
  
  def js path
    "<script src='javascripts/#{path}.js' type='text/javascript'></script>"
  end
  
end