# frozen_string_literal: true

require_relative 'lexer'
require_relative 'parser'

class Interpreter
  def initialize(path)
    @lexer = Lexer.new(path)
    @parser = Parser.new(@lexer)
  end

  def execute
    while @parser.has_more_lines?
      node = @parser.parse
      puts node.eval
    end
  ensure
    @lexer.close
  end
end
