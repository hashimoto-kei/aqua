# frozen_string_literal: true

class Lexer
  RESERVED_WORDS = [
    :true,
    :false,
    :if,
    :else,
    :while,
    :def,
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
      @token = generate_token(:eof, nil)
    in "\n" | '(' | ')' | '{' | '}' | '+' | '-' | '*' | ','
      @token = generate_token(c.to_sym, nil)
    in '='
      c = @input.getc
      case c
      in '='
        @token = generate_token(:eq, nil)
      else
        @input.ungetc(c)
        @token = generate_token(:'=', nil)
      end
    in '!'
      c = @input.getc
      case c
      in '='
        @token = generate_token(:ne, nil)
      else
        @input.ungetc(c)
        @token = generate_token(:!, nil)
      end
    in '>'
      c = @input.getc
      case c
      in '='
        @token = generate_token(:ge, nil)
      else
        @input.ungetc(c)
        @token = generate_token(:gt, nil)
      end
    in '<'
      c = @input.getc
      case c
      in '='
        @token = generate_token(:le, nil)
      else
        @input.ungetc(c)
        @token = generate_token(:lt, nil)
      end
    in '&'
      c = @input.getc
      case c
      in '&'
        @token = generate_token(:and, nil)
      end
    in '|'
      c = @input.getc
      case c
      in '|'
        @token = generate_token(:or, nil)
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
        @token = generate_token(:/, nil)
      end
    in /\d/
      @input.ungetc(c)
      @token = generate_token(:int, lex_digit)
    in '"'
      @token = generate_token(:string, lex_string)
    in /\w/
      @input.ungetc(c)
      symbol = lex_symbol
      type, value = RESERVED_WORDS.include?(symbol) ? [symbol, nil] : [:symbol, symbol]
      @token = generate_token(type, value)
    end
  end

  def close
    @input.close
  end

  private

  def generate_token(type, value)
    {type: type, value: value}
  end

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
    s = []
    loop do
      c = @input.getc
      case c
      in /\w/
        s << c
      else
        @input.ungetc(c)
        break
      end
    end
    s.join.to_sym
  end
end
