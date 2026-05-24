# frozen_string_literal: true

require_relative 'node_func_def'
require_relative 'symbol_resolver'

class BuiltIn
  def self.setup
    self.setup_p
  end

  private

  def self.setup_p
    func = Class.new do
      def eval
        x = SymbolResolver.get(:x)
        p x
        nil
      end
    end
    NodeFuncDef.new(:p, [:x], func.new).eval
  end
end
