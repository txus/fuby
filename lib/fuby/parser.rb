require 'fuby/ast'

module Fuby
  class Parser < Rubinius::Melbourne19
    def self.parse_string(string, name="(eval)", line=1)
      new(name, line).parse_string string
    end

    def process_iasgn(line, name, value)
      AST::InstanceVariableAssignment.new line, name, value
    end

    def process_defn(line, name, body)
      AST::Define.new line, name, body
    end

    def process_lasgn(line, name, body)
      AST::LocalVariableAssignment.new line, name, body
    end

    def process_str(line, str)
      AST::StringLiteral.new line, str
    end

    def process_dstr(line, str, array)
      AST::DynamicString.new line, str, array
    end
  end
end
