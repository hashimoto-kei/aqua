# frozen_string_literal: true

class Lexer
  RESERVED_WORDS = [
    :true,
    :false,
    :if,
    :else,
    :while,
  ]

  attr_reader :token

  def initialize(path)
    @input = File.open(path)
    @token = nil
  end

  def advance
    skip_white_spaces
    c = @input.getc
    case c
    in nil
      @token = {type: :eof, value: nil}
    in "\n" | '(' | ')' | '{' | '}' | '+' | '-' | '*'
      @token = {type: c.to_sym, value: nil}
    in '='
      c = @input.getc
      case c
      in '='
        @token = {type: :eq, value: nil}
      else
        @input.ungetc(c)
        @token = {type: :'=', value: nil}
      end
    in '!'
      c = @input.getc
      case c
      in '='
        @token = {type: :ne, value: nil}
      else
        @input.ungetc(c)
        @token = {type: :!, value: nil}
      end
    in '>'
      c = @input.getc
      case c
      in '='
        @token = {type: :ge, value: nil}
      else
        @input.ungetc(c)
        @token = {type: :gt, value: nil}
      end
    in '<'
      c = @input.getc
      case c
      in '='
        @token = {type: :le, value: nil}
      else
        @input.ungetc(c)
        @token = {type: :lt, value: nil}
      end
    in '&'
      c = @input.getc
      case c
      in '&'
        @token = {type: :and, value: nil}
      end
    in '|'
      c = @input.getc
      case c
      in '|'
        @token = {type: :or, value: nil}
      end
    in '/'
      c = @input.getc
      case c
      in '/'
        skip_comment_line
        advance
      in '*'
        skip_comment_lines
        advance
      else
        @input.ungetc(c)
        @token = {type: :/, value: nil}
      end
    in /\d/
      @input.ungetc(c)
      @token = {type: :int, value: lex_digit}
    in '"'
      @token = {type: :string, value: lex_string}
    in /\w/
      @input.ungetc(c)
      symbol = lex_symbol
      type, value = RESERVED_WORDS.include?(symbol) ? [symbol, nil] : [:symbol, symbol]
      @token = {type: type, value: value}
    end
  end

  def close
    @input.close
  end

  private

  def skip_white_spaces
    c = @input.getc
    while c != "\n" && c =~ /\s/
      c = @input.getc
    end
    @input.ungetc(c) unless c.nil?
  end

  def skip_comment_line
    c = @input.getc
    while c != "\n"
      c = @input.getc
    end
    @input.ungetc(c) unless c.nil?
  end

  def skip_comment_lines
    loop do
      c = @input.getc
      if c == '*'
        c = @input.getc
        if c == '/'
          break
        end
      end
    end
  end

  def lex_digit
    n = 0
    loop do
      c = @input.getc
      case c
      in /\d/
        n = n * 10 + c.to_i
      else
        @input.ungetc(c)
        break
      end
    end
    n
  end

  def lex_string
    s = []
    loop do
      c = @input.getc
      break if c == '"'
      if c == '\\'
        c = @input.getc
      end
      s << c
    end
    s.join
  end

  def lex_symbol
    symbol = []
    loop do
      c = @input.getc
      case c
      in /\w/
        symbol << c
      else
        @input.ungetc(c)
        break
      end
    end
    symbol.join.to_sym
  end
end
