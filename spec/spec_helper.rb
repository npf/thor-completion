require 'bundler/setup'

require 'simplecov'
SimpleCov.start do
  add_filter '/spec'
end

require 'thor/completion'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  def capture(stream)
    begin
      stream = stream.to_s
      eval("$#{stream} = StringIO.new", __FILE__, __LINE__)
      yield
      result = eval("$#{stream}".string, __FILE__, __LINE__)
    ensure
      eval("$#{stream} = #{stream.upcase}", __FILE__, __LINE__)
    end
    result
  end
end
