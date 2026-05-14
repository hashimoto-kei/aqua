# frozen_string_literal: true

class NodeFuncCall
  def initialize(func, args)
    @func = func
    @args = args
  end

  def eval
    func = SymbolTable.get(@func)
    if func.nil?
      raise "Runtime Error. undifined function: #{@func.to_sym}"
    end
    args = @args.map(&:eval)
    func.call(args)
  end
end
