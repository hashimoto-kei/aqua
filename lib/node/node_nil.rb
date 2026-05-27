# frozen_string_literal: true

require 'singleton'

class NodeNil
  include Singleton

  def eval = nil
end
