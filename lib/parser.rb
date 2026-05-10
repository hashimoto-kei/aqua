# frozen_string_literal: true

require_relative 'node_assign'
require_relative 'node_bin_op'
require_relative 'node_block'
require_relative 'node_empty'
require_relative 'node_false'
require_relative 'node_if_stmt'
require_relative 'node_int'
require_relative 'node_string'
require_relative 'node_symbol'
require_relative 'node_true'
require_relative 'node_unary_op'
require_relative 'node_while_stmt'

class Parser
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
    raise "Syntax Error. expected_token_types: #{expected_token_types}, actual_token_type: #{actual_token[:type]}, actual_token_value: #{actual_token[:value]}"
  end

  # program: stmt \n
  #        | stmt eof
  #        | \n
  #        | eof
  def program
    case @token[:type]
    in :new_line
      node = NodeEmpty.new
    in :eof
      node = NodeEmpty.new
    else
      node = stmt
      advance
      syntax_assert([:new_line, :eof], @token)
      node
    end
  end

  # stmt: if_stmt
  #     | while_stmt
  #     | expr
  #     | block
  def stmt
    case @token[:type]
    in :if
      node = if_stmt
    in :while
      node = while_stmt
    in :left_b
      node = block
    else
      node = expr
    end
  end

  # if_stmt: if ( expr ) stmt
  #        | if ( expr ) stmt else stmt
  def if_stmt
    syntax_assert([:if], @token)
    syntax_assert([:left_p], @next_token)
    advance(2)
    _cond = expr
    syntax_assert([:right_p], @next_token)
    advance(2)
    _then = stmt
    _else = nil
    if [:else].include?(@next_token[:type])
      advance(2)
      _else = stmt
    end
    node = NodeIfStmt.new(_cond, _then, _else)
  end

  # while_stmt: while ( expr ) stmt
  def while_stmt
    syntax_assert([:while], @token)
    syntax_assert([:left_p], @next_token)
    advance(2)
    _cond = expr
    syntax_assert([:right_p], @next_token)
    advance(2)
    _then = stmt
    node = NodeWhileStmt.new(_cond, _then)
  end

  # block: { \n [stmt \n]* }
  def block
    syntax_assert([:left_b], @token)
    syntax_assert([:new_line], @next_token)
    advance(2)
    stmts = []
    until @token[:type] == :right_b
      stmts << stmt
      syntax_assert([:new_line], @next_token)
      advance(2)
    end
    node = NodeBlock.new(stmts)
  end

  # expr: simple_expr
  #     | simple_expr == expr
  #     | simple_expr != expr
  #     | simple_expr >= expr
  #     | simple_expr >  expr
  #     | simple_expr <= expr
  #     | simple_expr <  expr
  def expr
    node = simple_expr
    if [:double_equal, :not_equal, :ge, :gt, :le, :lt].include?(@next_token[:type])
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
  #            | term || simple_expr
  def simple_expr
    node = term
    if [:+, :-, :or].include?(@next_token[:type])
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
  #     | factor && term
  def term
    node = factor
    if [:*, :/, :and].include?(@next_token[:type])
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
  #       | ! factor
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
      node = NodeTrue.instance
    in :false
      node = NodeFalse.instance
    in :- | :not
      op = @token[:type]
      advance
      node = factor
      node = NodeUnaryOp.new(op, node)
    in :left_p
      advance
      node = expr
      advance
      syntax_assert([:right_p], @token)
    in :symbol
      node = NodeSymbol.intern(@token[:value])
      if [:equal].include?(@next_token[:type])
        advance(2)
        rhs = expr
        node = NodeAssign.new(node, rhs)
      end
    end
    node
  end
end
