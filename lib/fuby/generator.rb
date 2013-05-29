class Rubinius::AST::Node
  def new_block_generator(g, arguments)
    blk = g.class.new

    blk.in = g.in if g.respond_to?(:in) # patch

    blk.name = g.state.name || :__block__
    blk.file = g.file
    blk.for_block = true

    blk.required_args = arguments.required_args
    blk.post_args = arguments.post_args
    blk.total_args = arguments.total_args

    blk
  end

  def new_generator(g, name, arguments=nil)
    meth = g.class.new

    meth.in = g.in if g.respond_to?(:in) # patch

    meth.name = name
    meth.file = g.file

    if arguments
      meth.required_args = arguments.required_args
      meth.post_args = arguments.post_args
      meth.total_args = arguments.total_args
      meth.splat_index = arguments.splat_index
      if arguments.respond_to? :block_index
        meth.block_index = arguments.block_index
      end
    end

    meth
  end
end

module Fuby
  class Generator < Rubinius::Generator
    attr_writer :in
    def in
      @in ||= {}
    end

    def freeze
      send :freeze, 0, false
    end
  end
end
