require 'thor'
require 'thor/completion'

class MyScript1 < Thor
  include Thor::Completion::Command
  class Subcommand < Thor
    class_option :subcommand_class_option_bool, type: :boolean

    desc 'subcommand_command', 'A subcommand command with one argument'
    def subcommand_command(arg)
      puts "A command output #{arg}"
    end
  end
  class_option :class_option_bool, type: :boolean

  desc 'subcommand', 'A subcommand'
  subcommand 'subcommand', Subcommand

  desc 'command', 'A command with one argument'
  method_option :option_str, type: :string
  method_option :option_bool, type: :boolean
  def command(arg)
    puts "A command output #{arg}"
  end
end

MyScript1.start unless File.basename($PROGRAM_NAME) == 'rspec'
