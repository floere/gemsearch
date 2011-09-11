# encoding: utf-8
#
require 'sinatra/base'
require 'picky'
require File.expand_path '../gem',    __FILE__
require File.expand_path '../logging', __FILE__

# This app shows how to integrate the Picky server directly
# inside a web app. However, if you really need performance
# and easy caching, this is not recommended.
#
class GemSearch < Sinatra::Application

  # We do this so we don't have to type
  # Picky:: in front of everything.
  #
  include Picky

  # Server.
  #

  # Define an index.
  #
  gems_index = Index.new :gems do
    source Sources::CSV.new(:name, :versions, :author, :dependencies, :summary, file: 'data/gems.csv')

    indexing removes_characters: /[^a-zA-Z0-9\s\/\_\-\"\&\|\.]/, # whitelist
             stopwords:          /\b(and|the|of|a|on|at|it|in|for|to)\b/,
             splits_text_on:     /[\s\/\_\-\"\&\|]/,
             substitutes_characters_with: CharacterSubstituters::WestEuropean.new # Normalizes special user input, Ä -> Ae, ñ -> n etc.

    category :name,
             similarity: Similarity::DoubleMetaphone.new(2),
             partial: Partial::Substring.new(from: 1),
             qualifiers: [:name, :gem]

    category :version,
             partial: Partial::Substring.new(from: 1),
             qualifiers: [:version],
             from: :versions

    category :author,
             similarity: Similarity::DoubleMetaphone.new(2),
             partial: Partial::Substring.new(from: 1),
             qualifiers: [:author, :authors, :written, :writer, :by]

    category :dependencies,
             similarity: Similarity::DoubleMetaphone.new(2),
             partial: Partial::Substring.new(from: 1),
             qualifiers: [:dependency, :dependencies, :depends, :using, :uses, :use, :needs]

    category :summary, partial: Partial::None.new
  end

  # Define a search over the books index.
  #
  gems = Search.new gems_index do
    searching removes_characters: /[^äöüáéíóúàèßa-zA-Z0-9\s\/\-\_\,\&\.\"\~\*\:]/, # Picky needs control chars *"~: to pass through.
              stopwords:          /\b(and|the|of|a|on|at|it|in|for)\b/,
              splits_text_on:     /[\s\/\-\_\,\&]+/,
              maximum_tokens: 5,
              substitutes_characters_with: CharacterSubstituters::WestEuropean.new # Normalizes special user input, Ä -> Ae, ñ -> n etc.

    boost [:summary, :name] => +4,
          [:name] => +1,
          [:summary] => -2
  end


  # Client.
  #

  set :static, true
  set :public, File.dirname(__FILE__)
  set :views,  File.expand_path('../views', __FILE__)
  set :haml,   :format => :html5

  # Root, the search page.
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

  # Renders the results into the json.
  #
  # You get the results from the (local) picky server and then
  # populate the result hash with rendered models.
  #
  get '/search/full' do
    results = gems.search params[:query], params[:ids] || 20, params[:offset] || 0
    AppLogger.info results
    results = results.to_hash
    results.extend Picky::Convenience
    results.populate_with AGem do |a_gem|
      a_gem.to_s
    end

    #
    # Or, to populate with the model instances, use:
    #   results.populate_with Book
    #
    # Then to render:
    #   rendered_entries = results.entries.map do |book| (render each book here) end
    #
    response['Cache-Control'] = 'public, max-age=36000'
    ActiveSupport::JSON.encode results
  end

  # Updates the search count while the user is typing.
  #
  get '/search/live' do
    results = gems.search params[:query], params[:ids] || 20, params[:offset] || 0
    response['Cache-Control'] = 'public, max-age=36000'
    results.to_json
  end

  helpers do

    def js path
      "<script src='javascripts/#{path}.js' type='text/javascript'></script>"
    end

  end

end