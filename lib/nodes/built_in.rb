# frozen_string_literal: true

require_relative 'node_func_def'
require_relative 'symbol_resolver'
require_relative 'symbol_table'

class BuiltIn
  def self.setup
    SymbolTable.set(:p, self.p)
  end

  private

  def self.p
    func = Class.new do
      def eval
        x = SymbolResolver.get(:x)
        p x
        nil
      end
    end
    NodeFuncDef.new(:p, [:x], func.new)
  end
end
