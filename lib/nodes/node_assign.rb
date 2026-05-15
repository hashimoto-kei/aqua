# frozen_string_literal: true

require_relative 'symbol_resolver'

class NodeAssign
  def initialize(lhs, rhs)
    @lhs = lhs
    @rhs = rhs
  end

  def eval
    symbol = @lhs.to_sym
    value = @rhs.eval
    SymbolResolver.set(symbol, value)
    value
  end
end
