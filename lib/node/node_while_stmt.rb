# frozen_string_literal: true

class NodeWhileStmt
  def initialize(_cond, _then)
    @cond = _cond
    @then = _then
  end

  def eval
    while @cond.eval
      @then.eval
    end
  end
end
