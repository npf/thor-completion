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
            Completion::Introspector.run(self.class, name)
            if options.dump
              puts Completion::Introspector
            else
              comp_line = ENV['COMP_LINE']
              comp_point = ENV['COMP_POINT']
              comp_key = ENV['COMP_KEY']
              comp_type = ENV['COMP_TYPE']
              puts Completion::Generator.match(comp_line, comp_point, comp_key, comp_type)
            end
          end
        end
      end
    end
  end
end
