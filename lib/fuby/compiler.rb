require 'fuby/parser'
require 'fuby/generator'
require 'fuby/runtime'

module Fuby
  class CompileError < Rubinius::CompileError
  end

  class Compiler < Rubinius::Compiler
    def self.eval(code, *args)
      file, line, binding, instance = '(eval)', 1, Runtime::Lobby.send(:binding), Runtime::Lobby
      args.each do |arg|
        case arg
        when String   then file    = arg
        when Integer  then line    = arg
        when Binding  then binding = arg
        when Runtime::ObjectType  then instance = arg
        else raise ArgumentError
        end
      end

      cm       = compile_eval(code, binding.variables, file, line)
      cm.scope = Rubinius::ConstantScope.new(Runtime)
      cm.name  = :__fuby__
      script   = Rubinius::CompiledMethod::Script.new(cm, file, true)
      be       = Rubinius::BlockEnvironment.new

      script.eval_binding = binding
      script.eval_source  = code
      cm.scope.script     = script

      be.under_context(binding.variables, cm)
      be.from_eval!
      be.call_on_instance(instance)
    end

    class Generator < Rubinius::Compiler::Generator
      stage :bytecode
      next_stage Rubinius::Compiler::Encoder

      def initialize(*)
        super
      ensure
        @processor = Fuby::Generator
      end
    end

    class Parser < Rubinius::Compiler::Parser
      def initialize(*)
        super
      ensure
        @processor = Fuby::Parser
      end
    end

    class FileParser < Parser
      stage :file
      next_stage Generator

      def input(file, line=1)
        @file = file
        @line = line
      end

      def parse
        create.parse_file
      end
    end

    # source string -> AST
    class StringParser < Parser
      stage :string
      next_stage Generator

      def input(string, name="(eval)", line=1)
        @input = string
        @file = name
        @line = line
      end

      def parse
        create.parse_string(@input)
      end
    end

    class EvalParser < StringParser
      stage :eval
      next_stage Generator

      def should_cache?
        @output.should_cache?
      end
    end
  end
end
