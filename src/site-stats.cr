class SiteStats
  include JSON::Serializable

  alias Langname = String

  @@lang_aliases = {
    "agda"         => "Agda",
    "awk"          => "Awk",
    "bash"         => "Bash",
    "bf"           => "BF",
    "brainfuck"    => "BF",
    "c"            => "C",
    "c++"          => "C++",
    "cpp"          => "C++",
    "gnuc"         => "C",
    "csharp"       => "C#",
    "c#"           => "C#",
    "clojure"      => "Clojure",
    "cobol"        => "COBOL",
    "coffeescript" => "CoffeeScript",
    "commonlisp"   => "Lisp",
    "coq"          => "Coq",
    "crystal"      => "Crystal",
    "d"            => "D",
    "dart"         => "Dart",
    "elixir"       => "Elixir",
    "erlang"       => "Erlang",
    "elm"          => "Elm",
    "factor"       => "Factor",
    "fish"         => "><>",
    "forth"        => "Forth",
    "fortran"      => "Fortran",
    "fsharp"       => "F#",
    "f#"           => "F#",
    "golang"       => "Go",
    "go"           => "Go",
    "groovy"       => "Groovy",
    "haskell"      => "Haskell",
    "haxe"         => "Haxe",
    "hexagony"     => "Hexagony",
    "idris"        => "Idris",
    "j"            => "J",
    "julia"        => "Julia",
    "janet"        => "Janet",
    "java"         => "Java",
    "java7"        => "Java",
    "java8"        => "Java",
    "java17"       => "Java",
    "javascript"   => "JS",
    "js"           => "JS",
    "k"            => "K",
    "kotlin"       => "Kotlin",
    "kotlin1.4"    => "Kotlin",
    "lisp"         => "Lisp",
    "lua"          => "Lua",
    "mysql"        => "SQL",
    "nim"          => "Nim",
    "objectivec"   => "Obj-C",
    "objc"         => "Obj-C",
    "ocaml"        => "OCaml",
    "pascal"       => "Pascal",
    "perl"         => "Perl",
    "php"          => "PHP",
    "powershell"   => "PowerShell",
    "prolog"       => "Prolog",
    "purescript"   => "PureScript",
    "pypy"         => "Python",
    "pypy3"        => "Python",
    "pypy364"      => "Python",
    "python"       => "Python",
    "python2"      => "Python",
    "python3"      => "Python",
    "q#"           => "Q#",
    "r"            => "R",
    "racket"       => "Racket",
    "raku"         => "Raku",
    "reason"       => "Reason",
    "riscv"        => "RISC-V",
    "ruby"         => "Ruby",
    "rust"         => "Rust",
    "rust2021"     => "Rust",
    "scala"        => "Scala",
    "scheme"       => "Scheme",
    "solidity"     => "Solidity",
    "sql"          => "SQL",
    "swift"        => "Swift",
    "tcl"          => "Tcl",
    "tex"          => "Tex",
    "typescript"   => "TS",
    "ts"           => "TS",
    "v"            => "V",
    "vb"           => "VB",
    "viml"         => "VimL",
    "wren"         => "Wren",
    "zig"          => "Zig",
  }

  def initialize(
    @username : String,
    @profile_url : String,
    solved_by_language : Hash(Langname, Int32)
  )
    @solved_by_language = Hash(Langname, Int32).new(0)
    solved_by_language.each do |lang, count|
      @solved_by_language[SiteStats.lang_alias(lang)] += count
    end
  end

  def self.lang_alias(name : Langname) : Langname
    # some sites have way too many aliases for C++ to list
    # explicitly with various compiler versions etc...
    return "C++" if name.downcase.includes?("c++")

    @@lang_aliases.fetch(name.downcase.gsub(/[\s-]+/, ""), name)
  end
end
