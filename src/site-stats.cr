class SiteStats
  include JSON::Serializable

  alias Langname = String

  @@lang_aliases = {
    "awk"        => "AWK",
    "bash"       => "Bash",
    "c"          => "C",
    "c++"        => "C++",
    "cpp"        => "C++",
    "csharp"     => "C#",
    "c#"         => "C#",
    "clojure"    => "Clojure",
    "commonlisp" => "Lisp",
    "crystal"    => "Crystal",
    "d"          => "D",
    "elixir"     => "Elixir",
    "fortran"    => "Fortran",
    "fsharp"     => "F#",
    "f#"         => "F#",
    "golang"     => "Go",
    "go"         => "Go",
    "haskell"    => "Haskell",
    "julia"      => "Julia",
    "janet"      => "Janet",
    "java"       => "Java",
    "javascript" => "JS",
    "js"         => "JS",
    "kotlin"     => "Kotlin",
    "lisp"       => "Lisp",
    "lua"        => "Lua",
    "nim"        => "Nim",
    "ocaml"      => "OCaml",
    "pascal"     => "Pascal",
    "perl"       => "Perl",
    "powershell" => "PS",
    "python"     => "Python",
    "python2"    => "Python",
    "python3"    => "Python",
    "raku"       => "Raku",
    "ruby"       => "Ruby",
    "rust"       => "Rust",
    "scala"      => "Scala",
    "scheme"     => "Scheme",
    "sql"        => "SQL",
    "tcl"        => "Tcl",
    "typescript" => "TS",
    "ts"         => "TS",
    "wren"       => "Wren",
    "zig"        => "Zig",
  }

  def initialize(
    @username : String,
    @profile_url : String,
    @solved_by_language : Hash(Langname, Int32)
  )
    @solved_by_language = @solved_by_language.transform_keys do |lang|
      @@lang_aliases.fetch(lang.downcase.gsub(/[\s-]/, ""), lang)
    end
  end
end
