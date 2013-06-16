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

    class LocalVariableAssignment < Rubinius::AST::LocalVariableAssignment
      def bytecode(g)
        if g.state.scope.search_local(@name)
          raise Fuby::CompileError, "cannot reassign local variable"
        end
        super
      end
    end

    class StringLiteral < Rubinius::AST::StringLiteral
      def bytecode(g)
        g.push_fuby(:String)
        super
        g.send :new, 1, false
      end
    end

    class DynamicString < Rubinius::AST::DynamicString
      def bytecode(g)
        g.push_fuby(:String)
        super
        g.send :new, 1, false
      end
    end

    class PatternMatch < Rubinius::AST::ReceiverCase
      def bytecode(g)
        pos(g)

        done = g.new_label

        g.push_self
        @receiver.bytecode(g)
        g.send :Array, 1, true

        @whens.each do |w|
          w.receiver_bytecode(g, done)
        end

        g.pop
        @else.bytecode(g)

        # See command in if about why using line 0
        g.set_line 0

        done.set!
      end
    end

    class Predicate < Rubinius::AST::Send
      def self.from_send(s)
        if s.is_a?(Rubinius::AST::Send)
          new(s.line, s.receiver, s.name)
        end
      end

      def binding
        @receiver.respond_to?(:name) && @receiver.name
      end

      def bytecode(g)
        pos(g)

        if @name == :_
          g.pop
          g.push_true
          return
        end

        # omit the receiver
        if @block
          @block.bytecode(g)
          g.send_with_block @name, 0, @privately
        elsif @vcall_style
          g.send_vcall @name
        else
          g.send @name, 0, @privately
        end
      end
    end

    class Pattern < Rubinius::AST::Node
      attr_accessor :conditions, :body, :single, :splat

      def initialize(line, conditions, body)
        @line = line
        @body = body || Rubinius::AST::NilLiteral.new(line)
        @splat = nil
        @conditions = conditions
      end

      def predicates
        @conditions.body
          .flatten.compact
          .map { |x| Predicate.from_send(x) }
          .flatten
      end

      def match_ruby(g, condition)
        condition.pos(g)
        condition.bytecode(g)
        g.swap
        g.send :===, 1
      end

      def match_predicate(g, condition)
        condition.pos(g)
        condition.bytecode(g)
      end

      def condition_bytecode(g, condition)
        case condition
        when Rubinius::AST::Send
          match_predicate(g, Predicate.from_send(condition))
        else
          match_ruby(g, condition)
        end
      end

      def bind_matched_predicates(g)
        predicates.each_with_index do |predicate, idx|
          if predicate && predicate.binding
            local_binding = LocalVariableAssignment.new(@body.line, predicate.binding, nil)
            ref = g.state.scope.assign_local_reference local_binding

            g.dup
            g.push idx
            g.send :[], 1
            ref.set_bytecode(g)
            g.pop
          end
        end
      end

      def receiver_bytecode(g, done)
        body = g.new_label
        nxt = g.new_label

        if @conditions
          @conditions.body.each_with_index do |c, idx|
            g.dup
            g.push idx
            g.send :[], 1
            condition_bytecode(g, c)
            g.git body
          end
        end

        @splat.receiver_bytecode(g, body, nxt) if @splat
        g.goto nxt

        body.set!

        bind_matched_predicates(g)

        g.pop
        @body.bytecode(g)
        g.goto done

        nxt.set!
      end
    end

    class SplatWhen < Rubinius::AST::Node
      attr_accessor :condition

      def initialize(line, condition)
        @line = line
        @condition = condition
      end

      def receiver_bytecode(g, body, nxt)
        pos(g)

        g.dup
        @condition.bytecode(g)
        g.cast_array
        g.push_literal Rubinius::Compiler::Runtime
        g.rotate(3)
        g.send :matches_when, 2
        g.git body
      end

      def bytecode(g, body, nxt)
        # TODO: why is this empty?
      end

      def to_sexp
        [:when, @condition.to_sexp, nil]
      end
    end
  end
end
