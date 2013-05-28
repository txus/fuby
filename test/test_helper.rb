require 'minitest/autorun'

$: << 'lib'
require 'fuby'

# class MiniTest::Unit::TestCase
# 
#   include Fuby::AST
# 
#   def tokenizes(input, expected)
#     lexer = Parser.new
#     lexer.scan_setup(input)
#     tokens = []
#     while token = lexer.next_token
#       tokens << token
#     end
# 
#     assert_equal expected, tokens
#   end
# 
#   def parses(input, &block)
#     parser = Parser.new
# 
#     show_tokens(input) if ENV['DEBUG']
# 
#     ast = parser.parse_string(input, "(test)")
#     block.call(ast.body.expressions)
#   end
# 
#   def compile(code)
#     Noscript.eval_noscript(code)
#   end
# 
#   def assert_output(stdout = nil, stderr = nil)
#     out, err = capture_io do
#       yield
#     end
# 
#     y = assert_equal stderr, err, "In stderr" if stderr
#     x = assert_equal stdout, out, "In stdout" if stdout
# 
#     (!stdout || x) && (!stderr || y)
#   end
# 
#   private
# 
#   def show_tokens(input)
#     lexer = Parser.new
#     lexer.scan_setup(input.strip)
#     tokens = []
#     while token = lexer.next_token
#       tokens << token
#     end
#     p tokens
#   end
# 
#   def show_ast(input)
#     parser = Parser.new
#     ast = parser.scan_str(input.strip)
#     p ast
#   end
# end