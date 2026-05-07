# frozen_string_literal: true

class NodeUnaryOp
  def initialize(op, operand)
    @op = op
    @operand = operand
  end

  def eval
    operand = @operand.eval
    case @op
    in :-
      - operand
    in :not
      ! operand
    end
  end
end
