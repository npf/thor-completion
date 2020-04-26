class Thor
  module Completion
    # Regexp build helper
    module Regexp
      class <<self
        def build_rec(str, regexp_str = '')
          return /^#{regexp_str}$/ if str.empty?
          build_rec(str[0..-2], "(?:#{escape_char(str[-1])}#{regexp_str})?")
        end

        def escape_char(char)
          to_escape = ['?', '*', '+', '(', ')', '{', '}', '[', ']', '^', ':', '!', '|', '\\', '-', '\$', '#']
          return "\\#{char}" if to_escape.include?(char)
          char
        end

        alias build build_rec
      end

      private_class_method :build_rec, :escape_char
    end
  end
end
