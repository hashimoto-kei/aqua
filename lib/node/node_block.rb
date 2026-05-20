# frozen_string_literal: true

class NodeBlock
  def initialize(stmts)
    @stmts = stmts
  end

  def eval
    ret = nil
    @stmts.each do |node|
      ret = node.eval
    end
    ret
  end
end
