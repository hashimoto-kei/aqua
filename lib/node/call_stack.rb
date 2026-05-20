# frozen_string_literal: true

class CallStack
  @@stack = []

  def self.push(frame)
    @@stack << frame
  end

  def self.pop
    @@stack.pop
  end

  def self.get(symbol)
    @@stack.last[symbol]
  end

  def self.set(symbol, value)
    @@stack.last[symbol] = value
  end

  def self.exist?(symbol)
    !@@stack.empty? && !@@stack.last[symbol].nil?
  end
end
