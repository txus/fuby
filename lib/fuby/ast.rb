module Fuby
  module AST
    class InstanceVariableAssignment < Rubinius::AST::InstanceVariableAssignment
      def bytecode(g)
        unless g.in[:constructor]
          raise Fuby::CompileError, "instance variable assignment outside constructor"
        end
        super
      end
    end

    class Define < Rubinius::AST::Define
      def bytecode(g)
        g.in[:constructor] = @name == :initialize
        super
      ensure
        g.in[:constructor] = false
      end
    end
  end
end
