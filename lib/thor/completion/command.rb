class Thor

  module Completion

    module Command

      def self.included(klass)
        klass.class_eval do
          desc "completion", "Print completion"
          def completion
            name = options.name || File.basename($0)
            comp_line = ENV["COMP_LINE"]
            comp_point = ENV["COMP_POINT"]
            comp_key = ENV["COMP_KEY"]
            comp_type = ENV["COMP_TYPE"]
            puts Completion::Generator.new(self.class, name).match(comp_line, comp_point, comp_key, comp_type)
          end
        end
      end

    end

  end

end
