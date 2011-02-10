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
  
  def initialize id, title, author
    @id, @title, @author = id, title, author
  end
  
  # "Rendering" ;)
  #
  # Note: This is just an example. Please do not render in the model.
  #
  def to_s
    "<div class='gem'><p>\"#{@title}\", by #{@author}</p></div>"
  end
  
end