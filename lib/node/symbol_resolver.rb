# frozen_string_literal: true

require_relative 'call_stack'
require_relative 'symbol_table'

class SymbolResolver
  def self.set(symbol, value)
    klass = CallStack.exist?(symbol) ? CallStack : SymbolTable
    klass.set(symbol, value)
  end

  def self.get(symbol)
    klass = CallStack.exist?(symbol) ? CallStack : SymbolTable
    klass.get(symbol)
  end

  def self.exist?(symbol)
    CallStack.exist?(symbol) || SymbolTable.exist?(symbol)
  end
end
