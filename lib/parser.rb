# frozen_string_literal: true

require_relative 'node_assign'
require_relative 'node_bin_op'
require_relative 'node_bool'
require_relative 'node_empty'
require_relative 'node_int'
require_relative 'node_string'
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
  #        | expr eof
  #        | \n
  #        | eof
  def program
    case @token[:type]
    in :new_line
      node = NodeEmpty.new
    in :eof
      node = NodeEmpty.new
    else
      node = expr
      advance
      syntax_assert([:new_line, :eof], @token)
      node
    end
  end

  # expr: simple_expr
  #     | simple_expr == expr
  def expr
    node = simple_expr
    if [:double_equal].include?(@next_token[:type])
      op = @next_token[:type]
      advance(2)
      rhs = expr
      node = NodeBinOp.new(op, node, rhs)
    end
    node
  end

  # simple_expr: term
  #            | term + simple_expr
  #            | term - simple_expr
  def simple_expr
    node = term
    if [:+, :-].include?(@next_token[:type])
      op = @next_token[:type]
      advance(2)
      rhs = simple_expr
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
  #       | string
  #       | true
  #       | false
  #       | - factor
  #       | ( expr )
  #       | symbol
  #       | symbol = expr
  def factor
    case @token[:type]
    in :int
      node = NodeInt.new(@token[:value])
    in :string
      node = NodeString.new(@token[:value])
    in :true
      node = NodeBool.new(@token[:value])
    in :false
      node = NodeBool.new(@token[:value])
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
      node = NodeSymbol.intern(@token[:value])
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
