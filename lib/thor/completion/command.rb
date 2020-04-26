class Thor
  module Completion
    # This is the command module, to be included in the main class of the target tool
    module Command
      def self.included(klass)
        klass.class_eval do
          desc 'completion', 'Print completion'
          method_option :dump, desc: 'List all possible commands', type: :boolean
          method_option :name, desc: 'Command name', type: :string
          def completion
            name = options.name || File.basename($PROGRAM_NAME)
            if options.dump
              puts Completion::Introspector.new(self.class, name)
            else
              generator = Completion::Generator.new(self.class, name)
              comp_line = ENV['COMP_LINE']
              puts generator.match(comp_line)
            end
          end
        end
      end
    end
  end
end
