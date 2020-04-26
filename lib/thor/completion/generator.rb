class Thor
  module Completion
    # This is the competion generator class: it build the completion data
    class Generator
      def initialize(thor, name)
        @introspector = Completion::Introspector.new(thor, name)
      end

      def match(line)
        words = line.split(/\s+/)[1..-1]
        words.push('') if line.match?(/\s$/)
        filter_rec(@introspector.to_h, words).flatten.uniq
      end

      def filter_rec(completion_hash, words)
        filtered_hash = completion_hash.select { |_k, v| words.first.match(v[:regexp]) }
        return filtered_hash.keys if words.size == 1
        filtered_hash.values.map { |v| filter_rec(v[:children], words[1..-1]) }
      end
      private :filter_rec
    end
  end
end
