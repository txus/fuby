require 'test_helper'

module Fuby
  describe Compiler do
    def compile(str)
      Compiler.eval(str)
    end

    describe 'an instance variable assignment' do
      describe 'in the constructor' do
        it 'compiles normally' do
          compile """
          class Foo
            def initialize
              @foo = 123
            end
          end
          """
        end
      end

      describe 'outside the constructor' do
        it 'complains about assigning an ivar' do
          proc {
            compile """
            class Foo
              def set_foo
                @foo = 123
              end
            end
            """
          }.must_raise CompileError
        end
      end
    end
  end
end
