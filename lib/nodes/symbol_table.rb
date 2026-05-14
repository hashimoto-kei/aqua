# frozen_string_literal: true

require_relative 'call_stack'

class SymbolTable
  @@table = {}

  def self.set(symbol, value)
    if CallStack.exist?(symbol)
      CallStack.set(symbol, value)
    else
      @@table[symbol] = value
    end
  end

  def self.get(symbol)
    if CallStack.exist?(symbol)
      CallStack.get(symbol)
    else
      @@table[symbol]
    end
  end
end
