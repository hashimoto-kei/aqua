# frozen_string_literal: true

class NodeBinOp
  def initialize(op, lhs, rhs)
    @op = op
    @lhs = lhs
    @rhs = rhs
  end

  def eval
    lhs = @lhs.eval
    if @op == :and && lhs == false
      return false
    end
    if @op == :or && lhs == true
      return true
    end
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
    in :le
      lhs <= rhs
    in :lt
      lhs < rhs
    in :and
      lhs && rhs
    in :or
      lhs || rhs
    end
  end
end
