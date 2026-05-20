# frozen_string_literal: true

require_relative 'symbol_resolver'

class NodeSymbol
  @@created = {}

  def initialize(symbol)
    @symbol = symbol
  end

  def self.intern(symbol)
    node = @@created[symbol]
    if node.nil?
      node = self.new(symbol)
      @@created[symbol] = node
    end
    node
  end

  def eval
    value = SymbolResolver.get(@symbol)
    if value.nil?
      raise "Runtime Error. undifined symbol: #{@symbol}"
    end
    value
  end

  def to_sym
    @symbol
  end
end
