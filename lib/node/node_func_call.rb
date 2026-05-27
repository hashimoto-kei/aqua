# frozen_string_literal: true

require_relative 'symbol_resolver'

class NodeFuncCall
  def initialize(func, args)
    @func = func
    @args = args
  end

  def eval
    func = SymbolResolver.get(@func)
    if func.nil?
      puts "Runtime Error. undifined function: #{@func}"
      exit 1
    end
    args = @args.map(&:eval)
    func.call(args)
  end
end
