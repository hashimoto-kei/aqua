# frozen_string_literal: true

class NodeBinOp
  def initialize(op, lhs, rhs)
    @op = op
    @lhs = lhs
    @rhs = rhs
  end

  def eval
    lhs = @lhs.eval
    rhs = @rhs.eval
    case @op
    in :+
      lhs + rhs
    in :-
      lhs - rhs
    in :*
      lhs * rhs
    in :/
      lhs / rhs
    in :double_equal
      lhs == rhs
    in :not_equal
      lhs != rhs
    in :ge
      lhs >= rhs
    in :gt
      lhs > rhs
    end
  end
end
