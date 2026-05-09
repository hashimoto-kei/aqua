# frozen_string_literal: true

class NodeIfStmt
  def initialize(_cond, _then, _else)
    @cond = _cond
    @then = _then
    @else = _else
  end

  def eval
    if @cond.eval
      return @then.eval
    end
    unless @else.nil?
      return @else.eval
    end
  end
end
