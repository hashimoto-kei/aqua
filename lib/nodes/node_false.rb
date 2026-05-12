# frozen_string_literal: true

require 'singleton'

class NodeFalse
  include Singleton

  def eval = false
end
