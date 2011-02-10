# encoding: utf-8
#
# TODO Adapt the generated example
#      (a library books finder) to what you need.
#
# Check the Wiki http://github.com/floere/picky/wiki for more options.
# Ask me or the google group if you have questions or specific requests.
#
class PickySearch < Application

  # Indexing: How text is indexed.
  #
  default_indexing removes_characters: /[^a-zA-Z0-9\s\/\_\-\"\&\.\|]/,
                   stopwords:          /\b(and|the|of|it|in|for)\b/,
                   splits_text_on:     /[\s\/\_\-\"\&\|]/

  # Querying: How query text is handled.
  #
  default_querying removes_characters: /[^a-zA-Z0-9\s\/\-\_\,\&\.\"\~\*\:]/, # Picky needs control chars *"~: to pass through.
                   stopwords:          /\b(and|the|of|it|in|for)\b/,
                   splits_text_on:     /[\s\/\-\_\,\&]+/,

                   maximum_tokens: 5, # Amount of tokens passing into a query (5 = default).
                   substitutes_characters_with: CharacterSubstituters::WestEuropean.new # Normalizes special user input, Ä -> Ae, ñ -> n etc.

  # Define an index. Use a database etc. source?
  # See http://github.com/floere/picky/wiki/Sources-Configuration#sources
  #
  gems_index = index :gems, Sources::CSV.new(:name, :versions, :author, :dependencies, file: '../data/gems.csv')
  gems_index.define_category :name,
                              similarity: Similarity::Phonetic.new(3),
                              partial: Partial::Substring.new(from: 1)
                              
  gems_index.define_category :version,
                             partial: Partial::Substring.new(from: 1),
                             qualifiers: [:version],
                             from: :versions
  
  gems_index.define_category :author,
                             similarity: Similarity::Phonetic.new(3),
                             partial: Partial::Substring.new(from: 1),
                             qualifiers: [:author, :authors, :written, :writer, :by]
                             
  gems_index.define_category :dependencies,
                             similarity: Similarity::Phonetic.new(3),
                             partial: Partial::Substring.new(from: 1),
                             qualifiers: [:dependency, :dependencies, :depends, :using, :uses, :use, :needs]
  
  options = { :weights => { [:name] => +3 } }
  
  full_gems = Query::Full.new gems_index, options
  live_gems = Query::Live.new gems_index, options

  route %r{\A/gems/full\Z} => full_gems
  route %r{\A/gems/live\Z} => live_gems
  
end