# frozen_string_literal: true

class Lexer
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
    in /\n/
      @token = {type: :new_line, value: nil}
    in /\(/
      @token = {type: :left_p, value: nil}
    in /\)/
      @token = {type: :right_p, value: nil}
    in /\+|-|\*|\//
      @token = {type: c.to_sym, value: nil}
    in /\d/
      @input.ungetc(c)
      @token = {type: :int, value: lex_digit}
    end
  end

  def close
    @input.close
  end

  private

  def skip_white_spaces
    c = @input.getc
    while c !~ /\n/ && c =~ /\s/
      c = @input.getc
    end
    @input.ungetc(c) unless c.nil?
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
end
