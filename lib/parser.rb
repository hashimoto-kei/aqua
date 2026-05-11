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
    advance
  end

  def parse
    program
  end

  def has_more_lines?
    @token[:type] != :eof
  end

  private

  def advance(n=1)
    n.times do
      @lexer.advance
      @token = @lexer.token
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
    in :"\n"
      node = NodeEmpty.new
    in :eof
      node = NodeEmpty.new
    else
      node = stmt
      syntax_assert([:"\n", :eof], @token)
    end
    advance
    node
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
    in :'{'
      node = block
    else
      node = expr
    end
  end

  # if_stmt: if ( expr ) stmt
  #        | if ( expr ) stmt else stmt
  def if_stmt
    syntax_assert([:if], @token)
    advance
    syntax_assert([:'('], @token)
    advance
    _cond = expr
    syntax_assert([:')'], @token)
    advance
    _then = stmt
    _else = nil
    if [:else].include?(@token[:type])
      advance
      _else = stmt
    end
    node = NodeIfStmt.new(_cond, _then, _else)
  end

  # while_stmt: while ( expr ) stmt
  def while_stmt
    syntax_assert([:while], @token)
    advance
    syntax_assert([:'('], @token)
    advance
    _cond = expr
    syntax_assert([:')'], @token)
    advance
    _then = stmt
    node = NodeWhileStmt.new(_cond, _then)
  end

  # block: { \n [stmt \n]* }
  def block
    syntax_assert([:'{'], @token)
    advance
    syntax_assert([:"\n"], @token)
    advance
    stmts = []
    until @token[:type] == :'}'
      stmts << stmt
      syntax_assert([:"\n"], @token)
      advance
    end
    advance
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
    if [:eq, :ne, :ge, :gt, :le, :lt].include?(@token[:type])
      op = @token[:type]
      advance
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
    if [:+, :-, :or].include?(@token[:type])
      op = @token[:type]
      advance
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
    if [:*, :/, :and].include?(@token[:type])
      op = @token[:type]
      advance
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
      advance
    in :string
      node = NodeString.new(@token[:value])
      advance
    in :true
      node = NodeTrue.instance
      advance
    in :false
      node = NodeFalse.instance
      advance
    in :- | :!
      op = @token[:type]
      advance
      node = factor
      node = NodeUnaryOp.new(op, node)
    in :'('
      advance
      node = expr
      syntax_assert([:')'], @token)
      advance
    in :symbol
      node = NodeSymbol.intern(@token[:value])
      advance
      if [:'='].include?(@token[:type])
        advance
        rhs = expr
        node = NodeAssign.new(node, rhs)
      end
    end
    node
  end
end
