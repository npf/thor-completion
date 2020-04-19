class Thor

  module Completion

    module Command

      def self.included(klass)
        klass.class_eval do
          desc "completion", "Print completion"
          def completion
            name = options.name || File.basename($0)
            puts Completion::Generator.new(self.class, name).to_yaml
          end
        end
      end

    end

  end

end
