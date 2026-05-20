# frozen_string_literal: true

require 'singleton'

class NodeTrue
  include Singleton

  def eval = true
end
