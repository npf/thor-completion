RSpec.describe Thor::Completion do
  before(:each) { Thor::Completion::Introspector.class_variable_set :@@completions, nil }
  let(:thor) do
    Class.new(Thor) {}
  end

  it 'has a version number' do
    expect(Thor::Completion::VERSION).not_to be nil
  end

  it 'should raise an error if introspector is run twice' do
    expect do
      Thor::Completion::Introspector.run(thor, 'whatever')
      Thor::Completion::Introspector.run(thor, 'whatelse')
    end.to raise_error('Inspector already run')
  end
end

RSpec.reset

RSpec.describe Thor::Completion do
  before(:each) { Thor::Completion::Introspector.class_variable_set :@@completions, nil }
  let(:thor) do
    Class.new(Thor) do
      desc 'command', 'A command'
      def command
        puts 'A command output'
      end
    end
  end

  subject { Thor::Completion::Introspector.run(thor, 'generator_spec') }
  it 'dumps all possible completions' do
    should eq [
      "'generator_spec help ARGS ARGS'",
      "'generator_spec -h ARGS ARGS'",
      "'generator_spec -? ARGS ARGS'",
      "'generator_spec --help ARGS ARGS'",
      "'generator_spec -D ARGS ARGS'",
      "'generator_spec command'"
    ]
  end
end
