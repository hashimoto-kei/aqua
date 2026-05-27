# frozen_string_literal: true

class NodeBlock
  def initialize(stmts)
    @stmts = stmts
  end

  def eval
    ret = nil
    @stmts.each do |stmt|
      ret = stmt.eval
    end
    ret
  end
end
