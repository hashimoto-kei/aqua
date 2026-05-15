# frozen_string_literal: true

class SymbolTable
  @@table = {}

  def self.set(symbol, value)
    @@table[symbol] = value
  end

  def self.get(symbol)
    @@table[symbol]
  end
end
