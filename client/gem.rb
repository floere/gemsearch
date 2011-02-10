# encoding: utf-8
#
require 'csv'

# A gem is simple, it has just:
#  * a title
#  * an author
#
class AGem
  
  @@gems_mapping = {}
  
  # Load the books on startup.
  #
  file_name = File.expand_path '../data/gems.csv', File.dirname(__FILE__)
  CSV.open(file_name, 'r').each do |row|
    @@gems_mapping[row.shift.to_i] = row
  end
  
  # Find uses a lookup table.
  #
  def self.find ids, _ = {}
    ids.map { |id| new(id, *@@gems_mapping[id]) }
  end
  
  attr_reader :id
  
  def initialize id, name, versions, authors, dependencies
    @id, @name, @versions = id, name, versions
    @authors      = authors.split(/\|/).join(', ')
    @dependencies = dependencies.split(/\|/).join(', ')
  end
  
  # "Rendering" ;)
  #
  # Note: This is just an example. Please do not render in the model.
  #
  def to_s
    dependencies = "<p class='dependencies'>#{@dependencies}</p>" if @dependencies && !@dependencies.empty?
    authors = "<p class='authors'>☺ #{@authors}</p>" if @authors && !@authors.empty?
    "<div class='gem'><p><a href='http://rubygems.org/gems/#{@name}'>#{@name}</a></p>#{dependencies}#{authors}</div>"
  end
  
end