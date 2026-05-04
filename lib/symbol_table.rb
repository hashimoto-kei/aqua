# frozen_string_literal: true

class SymbolTable
  @@table = {}

  def self.set(symbol, node)
    @@table[symbol] = node
  end

  def self.get(symbol)
    @@table[symbol]
  end
end
