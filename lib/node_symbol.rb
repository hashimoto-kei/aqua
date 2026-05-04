# frozen_string_literal: true

require_relative 'symbol_table'

class NodeSymbol
  def initialize(symbol)
    @symbol = symbol
  end

  def eval
    value = SymbolTable.get(@symbol)
    if value.nil?
      raise "Runtime Error. undifined symbol: #{@symbol}"
    end
    value
  end

  def to_sym
    @symbol
  end
end
