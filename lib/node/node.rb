# frozen_string_literal: true

require_relative 'built_in'
require_relative 'node_assign'
require_relative 'node_bin_op'
require_relative 'node_block'
require_relative 'node_false'
require_relative 'node_func_call'
require_relative 'node_func_def'
require_relative 'node_if_stmt'
require_relative 'node_int'
require_relative 'node_string'
require_relative 'node_symbol'
require_relative 'node_true'
require_relative 'node_unary_op'
require_relative 'node_while_stmt'

BuiltIn.setup
