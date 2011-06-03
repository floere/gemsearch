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
  indexing removes_characters: /[^a-zA-Z0-9\s\/\_\-\"\&\|\.]/, # whitelist
           stopwords:          /\b(and|the|of|a|on|at|it|in|for|to)\b/,
           splits_text_on:     /[\s\/\_\-\"\&\|]/,
           substitutes_characters_with: CharacterSubstituters::WestEuropean.new # Normalizes special user input, Ä -> Ae, ñ -> n etc.

  # Querying: How query text is handled.
  #
  searching removes_characters: /[^äöüáéíóúàèßa-zA-Z0-9\s\/\-\_\,\&\.\"\~\*\:]/, # Picky needs control chars *"~: to pass through.
            stopwords:          /\b(and|the|of|a|on|at|it|in|for)\b/,
            splits_text_on:     /[\s\/\-\_\,\&]+/,
            maximum_tokens: 5,
            substitutes_characters_with: CharacterSubstituters::WestEuropean.new # Normalizes special user input, Ä -> Ae, ñ -> n etc.

  # Define an index. Use a database etc. source?
  # See http://github.com/floere/picky/wiki/Sources-Configuration#sources
  #
  gems = Index::Memory.new :gems do
    source Sources::CSV.new(:name, :versions, :author, :dependencies, :summary, file: 'data/gems.csv')

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

  route %r{\A/admin\Z} => LiveParameters.new
  # [:summary, :name] => +4
  route %r{\A/gems\Z} => Search.new(gems,
    :weights => {
      [:summary, :name] => +4,
      [:name] => +1,
      [:summary] => -2
    }
  )

end
