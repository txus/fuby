require 'test_helper'

module Fuby
  describe Compiler do
    def compile(str)
      Compiler.eval(str)
    end

    describe 'a string' do
      it 'is a Fuby::String' do
        compile('"foo"').must_be_kind_of Fuby::String
      end
      describe 'when dynamic' do
        it 'is also a Fuby::String' do
          compile('"foo #{3}"').must_be_kind_of Fuby::String
        end
      end
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

    describe 'a local variable' do
      describe 'when assigned the first time' do
        it 'is okay' do
          compile """
          a = 123
          """
        end
      end

      describe 'when assigned a second time' do
        it 'raises an error' do
          proc {
            compile """
            a = 123
            a = 234
            """
          }.must_raise CompileError
        end
      end

      describe 'when assigned a second time in an inner scope' do
        it 'raises an error' do
          proc {
            compile """
            a = 123
            lambda {
              a = 234
            }
            """
          }.must_raise CompileError
        end
      end
    end

    describe 'pattern matching' do
      it 'needs a receiver' do
        proc {
          compile """
          case
          when :foo
            :bar
          end
          """
        }.must_raise CompileError
      end

      it 'matches a single class' do
        compile("""
        case 1
        when Integer
          3
        else
          10
        end
        """).must_equal 3
      end

      it 'matches a regular expression' do
        compile("""
        case 'foo'
        when /foo/
          3
        else
          10
        end
        """).must_equal 3
      end

      it 'matches a predicate' do
        compile("""
        case 1
        when a.odd?
          a + 2
        else
          99
        end
        """).must_equal 3
      end

      it 'matches a predicate when shadowed by a local var' do
        compile("""
        a = 8
        case 1
        when a.odd?
          a + 2
        else
          99
        end
        """).must_equal 3
      end

      it 'matches destructuring' do
        compile("""
        case [100, 2, 1]
        when Integer, x.even?, _
          x + 1
        else
          10
        end
        """).must_equal 3
      end
    end
  end
end
