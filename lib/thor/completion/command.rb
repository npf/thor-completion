class Thor
  module Completion
    # This is the command module, to be included in the main class of the target tool
    module Command
      def self.included(klass)
        klass.class_eval do
          desc 'completion', 'Print completion', hide: true
          method_option :dump, desc: 'List all possible commands', type: :boolean
          method_option :name, desc: 'Tool name', type: :string
          method_option :line, desc: 'Command line to complete (as set in the $COMP_LINE environment variable)',
                               type: :string
          def completion(*_args) # when called by `complete -C <command>`, 3 useless arguments a passed
            name = options.name || File.basename($PROGRAM_NAME)
            if options.dump
              puts Completion::Introspector.new(self.class, name)
            else
              line = options.line.nil? ? ENV['COMP_LINE'] : "#{name} #{options.line}"
              raise Completion::Error, 'Completion line is not set' if line.nil?
              generator = Completion::Generator.new(self.class, name)
              puts generator.match(line)
            end
          end
        end
      end
    end
  end
end
