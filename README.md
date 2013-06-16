# Fuby
### Functional Ruby

Fuby is a hybrid functional/object-oriented programming language with the same
syntax as Ruby, although pretty different semantics in many aspects.

It targets the Rubinius VM, so you need to install Rubinius to run it.

It is just an idea for now. Some of its features might or might not be:

* Pervasive immutability
* Controlled IO
* Methods as first-class functions
* [Some] laziness
* Monads

Keep checking this repository for new ideas, code examples and so on :)

## Features

Fuby starts out as a fully compliant Ruby interpreter, and as I develop more and
more, its semantics will differ more and more from Ruby, normally in backwards
incompatible ways. Here's what's implemented for now:

### Immutable strings

All strings are instances of Fuby::String, which is an immutable kind of String.

### Variables are not reassignable

Variables cannot be reassigned a different value.

```ruby
a = 3
a = 5 # will raise a Fuby::CompileError
```

### Real pattern matching

Pattern matching is implemented in `case` statements. If you want to match in
the old ruby style, with procs or regexes or classes, you still can:

```ruby
case 1
when Integer
  3
else
  10
end
# => 3
```

But the interesting part is matching **predicates** that will bind variables
inside the `when` body:

```ruby
case 1
when x.odd?
  x + 2
else
  10
end
# => 3
```

And the best is that it works with any destructurable sequence. And you can
ignore a certain value with `_`:

```ruby
case [100, 2, :foo]
when Integer, x.even?, _
  x + 1
else
  10
end
# => 3
```

## Installation

After installing Rubinius, install Fuby as a gem:

    $ gem install fuby

## Usage

    $ fuby my_program.fb

## Who's this

This was made by [Josep M. Bach (Txus)](http://txustice.me) under the MIT
license. I'm [@txustice][twitter] on twitter (where you should probably follow
me!).

[twitter]: https://twitter.com/txustice
