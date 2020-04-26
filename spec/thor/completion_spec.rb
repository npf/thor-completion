RSpec.describe Thor::Completion do
  describe 'Sanity checks' do
    it 'has a version number' do
      expect(Thor::Completion::VERSION).not_to be nil
    end
  end

  describe 'Introspector' do
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
        "'thor_cli help ARGS ARGS'",
        "'thor_cli -h ARGS ARGS'",
        "'thor_cli -? ARGS ARGS'",
        "'thor_cli --help ARGS ARGS'",
        "'thor_cli -D ARGS ARGS'",
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
        "'thor_cli help ARGS ARGS'",
        "'thor_cli -h ARGS ARGS'",
        "'thor_cli -? ARGS ARGS'",
        "'thor_cli --help ARGS ARGS'",
        "'thor_cli -D ARGS ARGS'",
        "'thor_cli command ARGS'"
      ]
    end

    let(:thor3) do
      Class.new(Thor) do
        desc 'command', 'A command'
        method_option 'option', type: :boolean
        def command(arg)
          puts "A command output #{arg}"
        end
      end
    end

    it 'dumps correct completions for a command with an argument and an option' do
      expect(Thor::Completion::Introspector.new(thor3, 'thor_cli').to_a).to eq [
        "'thor_cli help ARGS ARGS'",
        "'thor_cli -h ARGS ARGS'",
        "'thor_cli -? ARGS ARGS'",
        "'thor_cli --help ARGS ARGS'",
        "'thor_cli -D ARGS ARGS'",
        "'thor_cli command ARGS --option'",
        "'thor_cli command --option ARGS'"
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
        "'thor_cli help ARGS ARGS --classoption'",
        "'thor_cli help ARGS --classoption ARGS'",
        "'thor_cli help --classoption ARGS ARGS'",
        "'thor_cli -h ARGS ARGS --classoption'",
        "'thor_cli -h ARGS --classoption ARGS'",
        "'thor_cli -h --classoption ARGS ARGS'",
        "'thor_cli -? ARGS ARGS --classoption'",
        "'thor_cli -? ARGS --classoption ARGS'",
        "'thor_cli -? --classoption ARGS ARGS'",
        "'thor_cli --help ARGS ARGS --classoption'",
        "'thor_cli --help ARGS --classoption ARGS'",
        "'thor_cli --help --classoption ARGS ARGS'",
        "'thor_cli -D ARGS ARGS --classoption'",
        "'thor_cli -D ARGS --classoption ARGS'",
        "'thor_cli -D --classoption ARGS ARGS'",
        "'thor_cli command ARGS --option --classoption'",
        "'thor_cli command ARGS --classoption --option'",
        "'thor_cli command --option ARGS --classoption'",
        "'thor_cli command --option --classoption ARGS'",
        "'thor_cli command --classoption ARGS --option'",
        "'thor_cli command --classoption --option ARGS'",
        "'thor_cli --classoption help ARGS ARGS'",
        "'thor_cli --classoption -h ARGS ARGS'",
        "'thor_cli --classoption -? ARGS ARGS'",
        "'thor_cli --classoption --help ARGS ARGS'",
        "'thor_cli --classoption -D ARGS ARGS'",
        "'thor_cli --classoption command ARGS --option'",
        "'thor_cli --classoption command --option ARGS'"
      ]
    end
  end
end
