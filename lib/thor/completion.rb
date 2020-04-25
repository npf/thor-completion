require 'thor'
require 'thor/completion/version'

class Thor
  module Completion
    class Error < StandardError; end
    # Your code goes here...
  end
end

require 'thor/completion/command'
require 'thor/completion/generator'
