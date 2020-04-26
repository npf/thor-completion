class Thor
  module Completion
    # This is the command module, to be included in the main class of the target tool
    module Command
      def self.included(klass)
        klass.class_eval do
          desc 'completion', 'Print completion', hide: true
          long_desc <<-LONGDESC
          `#{$PROGRAM_NAME} completion` will handle the shell completion for the #{$PROGRAM_NAME} command

          In a bash shell, the completion setup can achieved by running the following command:

          `eval $(#{$PROGRAM_NAME} completion --bash-setup)`

          Other options are for debugging only.
          LONGDESC
          method_option :bash_setup, desc: 'Print the bash completion setup command', type: :boolean
          method_option :dump, desc: 'List all possible commands', type: :boolean
          method_option :name, desc: 'Set the tool name', type: :string
          method_option :line, desc: 'Give the command line to complete (replace $COMP_LINE)',
                               type: :string
          # when called by `complete -C <command>`, 3 useless arguments a passed
          def completion(*_args)
            if options.bash_setup
              puts "complete -C '#{$PROGRAM_NAME} completion' #{$PROGRAM_NAME}"
              return
            end
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
