# frozen_string_literal: true

require_relative 'lexer'
require_relative 'parser'

class Interpreter
  def initialize(path, options)
    @lexer = Lexer.new(path)
    @parser = Parser.new(@lexer)
    @options = options
  end

  def execute
    while @parser.more_tokens?
      node = @parser.parse
      result = node&.eval
      puts result if @options[:verbose] && !result.nil?
    end
  ensure
    @lexer.close
  end
end
