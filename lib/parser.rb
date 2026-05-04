# frozen_string_literal: true

require_relative 'node_assing'
require_relative 'node_bin_op'
require_relative 'node_int'
require_relative 'node_symbol'
require_relative 'node_unary_op'

class Parser
  SYNTAX_ERROR = 'Syntax Error'

  def initialize(lexer)
    @lexer = lexer
    @token = nil
    @next_token = nil
    advance
  end

  def parse
    advance
    program
  end

  def has_more_lines?
    @next_token.nil? || @next_token[:type] != :eof
  end

  private

  def advance(n=1)
    n.times do
      @lexer.advance
      @token = @next_token
      @next_token = @lexer.token
    end
  end

  def syntax_assert(expected_token_types, actual_token)
    unless expected_token_types.include?(actual_token[:type])
      syntax_error(expected_token_types, actual_token)
    end
  end

  def syntax_error(expected_token_types, actual_token)
    raise "#{SYNTAX_ERROR}. expected_token_types: #{expected_token_types}, actual_token_type: #{actual_token[:type]}, actual_token_value: #{actual_token[:value]}"
  end

  # program: expr \n
  def program
    node = expr
    advance
    syntax_assert([:new_line, :eof], @token)
    node
  end

  # expr: term
  #     | term + expr
  #     | term - expr
  def expr
    node = term
    if [:+, :-].include?(@next_token[:type])
      op = @next_token[:type]
      advance(2)
      rhs = expr
      node = NodeBinOp.new(op, node, rhs)
    end
    node
  end

  # term: factor
  #     | factor * term
  #     | factor / term
  def term
    node = factor
    if [:*, :/].include?(@next_token[:type])
      op = @next_token[:type]
      advance(2)
      rhs = term
      node = NodeBinOp.new(op, node, rhs)
    end
    node
  end

  # factor: int
  #       | - factor
  #       | ( expr )
  #       | symbol
  #       | symbol = expr
  def factor
    case @token[:type]
    in :int
      node = NodeInt.new(@token[:value])
    in :-
      op = @token[:type]
      advance
      node = factor
      node = NodeUnaryOp.new(op, node)
    in :left_p
      advance
      node = expr
      advance
      syntax_assert([:int, :right_p], @token)
    in :symbol
      node = NodeSymbol.new(@token[:value])
      if [:equal].include?(@next_token[:type])
        advance(2)
        rhs = expr
        node = NodeAssign.new(node, rhs)
      end
    else
      syntax_error([:int, :-, :left_p], @token)
    end
    node
  end
end
