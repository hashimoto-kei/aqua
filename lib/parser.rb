# frozen_string_literal: true

require_relative 'node/node'

class Parser
  def initialize(lexer)
    @lexer = lexer
    @token = nil
    advance
  end

  def parse
    program
  end

  def more_tokens?
    @token[:type] != :eof
  end

  private

  def advance(*tokens)
    syntax_assert(tokens, @token) unless tokens.empty?
    @lexer.advance
    @token = @lexer.token
  end

  def syntax_assert(expected_token_types, actual_token)
    unless expected_token_types.include?(actual_token[:type])
      syntax_error(expected_token_types, actual_token)
    end
  end

  def syntax_error(expected_token_types, actual_token)
    raise "Syntax Error. expected_token_types: #{expected_token_types}, actual_token_type: #{actual_token[:type]}, actual_token_value: #{actual_token[:value]}"
  end

  # program: [stmt] ('\n' | eof)
  def program
    unless [:"\n", :eof].include?(@token[:type])
      node = stmt
    end
    advance(:"\n", :eof)
    node
  end

  # stmt: if_stmt
  #     | while_stmt
  #     | block
  #     | func_def
  #     | expr
  def stmt
    case @token[:type]
    in :if
      node = if_stmt
    in :while
      node = while_stmt
    in :'{'
      node = block
    in :def
      node = func_def
    else
      node = expr
    end
  end

  # if_stmt: if '(' expr ')' stmt [else stmt]
  def if_stmt
    advance(:if)
    advance(:'(')
    _cond = expr
    advance(:')')
    _then = stmt
    _else = nil
    if @token[:type] == :else
      advance
      _else = stmt
    end
    node = NodeIfStmt.new(_cond, _then, _else)
  end

  # while_stmt: while '(' expr ')' stmt
  def while_stmt
    advance(:while)
    advance(:'(')
    _cond = expr
    advance(:')')
    _then = stmt
    node = NodeWhileStmt.new(_cond, _then)
  end

  # block: '{' '\n' [stmt '\n']* '}'
  def block
    advance(:'{')
    advance(:"\n")
    stmts = []
    until @token[:type] == :'}'
      stmts << stmt
      advance(:"\n")
    end
    advance
    node = NodeBlock.new(stmts)
  end

  # func_def: def symbol '(' [symbol [, symbol]*] ')' block
  def func_def
    advance(:def)
    func = @token[:value]
    advance(:symbol)
    advance(:'(')
    args = []
    unless @token[:type] == :')'
      args << @token[:value]
      advance(:symbol)
      until @token[:type] == :')'
        advance(:',')
        args << @token[:value]
        advance(:symbol)
      end
    end
    advance(:')')
    body = block
    node = NodeFuncDef.new(func, args, body)
  end

  # expr: simple_expr
  #     | simple_expr '==' expr
  #     | simple_expr '!=' expr
  #     | simple_expr '>=' expr
  #     | simple_expr '>'  expr
  #     | simple_expr '<=' expr
  #     | simple_expr '<'  expr
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
  #            | term [('+' | '-') term]+
  #            | term '||' simple_expr
  def simple_expr
    node = term
    if [:or].include?(@token[:type])
      op = @token[:type]
      advance
      rhs = simple_expr
      node = NodeBinOp.new(op, node, rhs)
    elsif [:+, :-].include?(@token[:type])
      loop do
        op = @token[:type]
        advance
        rhs = term
        node = NodeBinOp.new(op, node, rhs)
        break unless [:+, :-].include?(@token[:type])
      end
    end
    node
  end

  # term: factor
  #     | factor [('*' | '/') factor]+
  #     | factor '&&' term
  def term
    node = factor
    if [:and].include?(@token[:type])
      op = @token[:type]
      advance
      rhs = term
      node = NodeBinOp.new(op, node, rhs)
    elsif [:*, :/].include?(@token[:type])
      loop do
        op = @token[:type]
        advance
        rhs = factor
        node = NodeBinOp.new(op, node, rhs)
        break unless [:*, :/].include?(@token[:type])
      end
    end
    node
  end

  # factor: int
  #       | string
  #       | true
  #       | false
  #       | '-' factor
  #       | '!' factor
  #       | '(' expr ')'
  #       | symbol
  #       | symbol '=' expr
  #       | symbol '(' [expr [, expr]*] ')'
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
      advance(:')')
    in :symbol
      node = NodeSymbol.intern(@token[:value])
      advance
      if @token[:type] == :'='
        advance
        rhs = expr
        node = NodeAssign.new(node, rhs)
      elsif @token[:type] == :'('
        advance
        exprs = []
        unless @token[:type] == :')'
          exprs << expr
          until @token[:type] == :')'
            advance(:',')
            exprs << expr
          end
        end
        advance
        node = NodeFuncCall.new(node.to_sym, exprs)
      end
    end
    node
  end
end
