RSpec.describe Thor::Completion do
  describe 'Sanity checks' do
    it 'has a version number' do
      expect(Thor::Completion::VERSION).not_to be nil
    end
  end

  describe 'Test Introspector' do
    let(:thor) do
      Class.new(Thor) do
        desc 'command', 'A command'
        def command
          puts 'A command output'
        end
      end
    end

    it 'dumps correct completions for a command' do
      expect(Thor::Completion::Introspector.new(thor, 'thor_cli').to_a).to eq [
        "'thor_cli command'"
      ]
    end

    let(:thor2) do
      Class.new(Thor) do
        desc 'command', 'A command'
        def command(arg)
          puts "A command output #{arg}"
        end
      end
    end

    it 'dumps correct completions for a command with an argument' do
      expect(Thor::Completion::Introspector.new(thor2, 'thor_cli').to_a).to eq [
        "'thor_cli command ARGVAL'"
      ]
    end

    let(:thor3) do
      Class.new(Thor) do
        desc 'command', 'A command'
        method_option 'option', type: :string
        def command(arg)
          puts "A command output #{arg}"
        end
      end
    end

    it 'dumps correct completions for a command with an argument and an option' do
      expect(Thor::Completion::Introspector.new(thor3, 'thor_cli').to_a).to eq [
        "'thor_cli command ARGVAL --option OPTVAL'",
        "'thor_cli command ARGVAL --option=OPTVAL'",
        "'thor_cli command --option OPTVAL ARGVAL'",
        "'thor_cli command --option=OPTVAL ARGVAL'"
      ]
    end

    let(:thor4) do
      Class.new(Thor) do
        class_option :classoption, type: :boolean

        desc 'command', 'A command with one argument and one option and a class option'
        method_option 'option', type: :boolean
        def command(arg)
          puts "A command output #{arg}"
        end
      end
    end

    it 'dumps completions for a simple command with an argument and an option' do
      expect(Thor::Completion::Introspector.new(thor4, 'thor_cli').to_a).to eq [
        "'thor_cli command ARGVAL --option --classoption'",
        "'thor_cli command ARGVAL --classoption --option'",
        "'thor_cli command --option ARGVAL --classoption'",
        "'thor_cli command --option --classoption ARGVAL'",
        "'thor_cli command --classoption ARGVAL --option'",
        "'thor_cli command --classoption --option ARGVAL'",
        "'thor_cli --classoption command ARGVAL --option'",
        "'thor_cli --classoption command --option ARGVAL'"
      ]
    end

    let(:thor5) do
      Class.new(Thor) do
        class Subcommand < Thor
          class_option :subcommand_class_option, type: :boolean

          desc 'subcommand_command', 'A subcommand command with one argument'
          def subcommand_command(arg)
            puts "A command output #{arg}"
          end
        end
        class_option :class_option, type: :boolean

        desc 'subcommand', 'A subcommand'
        subcommand 'subcommand', Subcommand

        desc 'command', 'A command with one argument'
        def command(arg)
          puts "A command output #{arg}"
        end
      end
    end

    it 'dumps completions for a simple command with an argument and an option' do
      # puts Thor::Completion::Introspector.new(thor5, 'thor_cli').to_a
      expect(Thor::Completion::Introspector.new(thor5, 'thor_cli').to_a).to eq [
        "'thor_cli subcommand subcommand_command ARGVAL'",
        "'thor_cli command ARGVAL'",
        "'thor_cli --class-option subcommand subcommand_command ARGVAL'",
        "'thor_cli --class-option command ARGVAL'"
      ]
    end
  end
  describe 'Test completion' do
    it 'dumps its completions' do
      expect(capture(:stdout) { MyScript1.start(%w[completion --dump --name=MyScript]) }).to eq <<-MYSCRIPTOUTPUT
'MyScript subcommand subcommand_command ARGVAL'
'MyScript command ARGVAL --option OPTVAL'
'MyScript command ARGVAL --option=OPTVAL'
'MyScript command --option OPTVAL ARGVAL'
'MyScript command --option=OPTVAL ARGVAL'
'MyScript --class-option subcommand subcommand_command ARGVAL'
'MyScript --class-option command ARGVAL --option OPTVAL'
'MyScript --class-option command ARGVAL --option=OPTVAL'
'MyScript --class-option command --option OPTVAL ARGVAL'
'MyScript --class-option command --option=OPTVAL ARGVAL'
MYSCRIPTOUTPUT
    end

    it 'gives a completion' do
      expect(capture(:stdout) { MyScript1.start(%w[completion --name=MyScript --line co]) }).to eq <<-COMPLETION
command
COMPLETION
    end

    it 'gives another completion' do
      expect(capture(:stdout) { MyScript1.start(%w[completion --name=MyScript --line command\ ]) }).to eq <<-COMPLETION
ARGVAL
--option
--option=OPTVAL
COMPLETION
    end
  end
end
