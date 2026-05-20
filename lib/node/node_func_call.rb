# frozen_string_literal: true

require_relative 'symbol_resolver'

class NodeFuncCall
  def initialize(func_name, args)
    @func_name = func_name
    @args = args
  end

  def eval
    func = SymbolResolver.get(@func_name)
    if func.nil?
      raise "Runtime Error. undifined function: #{@func_name}"
    end
    args = @args.map(&:eval)
    func.call(args)
  end
end
