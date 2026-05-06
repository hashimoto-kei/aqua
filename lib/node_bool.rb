# frozen_string_literal: true

class NodeBool
  def initialize(value)
    @value = value
  end

  def eval
    @value
  end
end
