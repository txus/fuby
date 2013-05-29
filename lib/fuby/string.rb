module Fuby
  class String < ::String
    instance_methods.grep(/!/).each { |mutator_method|
      undef_method mutator_method
    }

    def initialize(*)
      super
      freeze
    end
  end
end
