# frozen_string_literal: true

class NodeBlock
  def initialize(stmts)
    @stmts = stmts
  end

  def eval
    @stmts.each do |node|
      node.eval
    end
  end
end
