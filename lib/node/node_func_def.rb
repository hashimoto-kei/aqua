# frozen_string_literal: true

require_relative 'call_stack'
require_relative 'symbol_resolver'

class NodeFuncDef
  def initialize(func_name, arg_names, body)
    @func_name = func_name
    @arg_names = arg_names
    @body = body
  end

  def eval
    SymbolResolver.set(@func_name, self)
    nil
  end

  def call(args)
    local_table = generate_local_table(args)
    CallStack.push(local_table)
    ret = @body.eval
    CallStack.pop
    ret
  end

  private

  def generate_local_table(args)
    local_table = {}
    @arg_names.each_with_index do |arg_name, i|
      local_table[arg_name] = args[i]
    end
    local_table
  end
end
