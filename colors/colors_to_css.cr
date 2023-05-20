require "json"

# Builds a css with the language colors in Github.

# The json can be found at:
# https://github.com/ozh/github-colors/blob/master/colors.json

colorsjson = Hash(String, JSON::Any).new
File.open("colors.json") do |file|
  colorsjson = JSON.parse(file).as_h
end

colorsjson.each do |lang, data|
  lang = lang.gsub(/\W/, {
    " " => "-",
    "+" => "plus",
    "#" => "sharp",
    "*" => "star",
    # other non-word characters just get removed
  })
  color = data["color"]

  puts <<-CSS
  .bar.#{lang} {
    background-color: #{color};
  }
  CSS
end
