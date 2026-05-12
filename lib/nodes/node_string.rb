# frozen_string_literal: true

class NodeString
  def initialize(value)
    @value = value
  end

  def eval
    @value
  end
end
