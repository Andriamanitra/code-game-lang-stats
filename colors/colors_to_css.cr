require "json"

# Builds a css with the language colors in Github.

# The json can be found at:
# https://github.com/ozh/github-colors/blob/master/colors.json

json_string = File.read("colors.json")
json = JSON.parse(json_string)

css_content = [] of String
json.as_h.each do |lang, data|
  lang = lang.gsub(/ /, "-")
  color = data["color"]

  css_entry = ".bar.#{lang} {\n  background-color: #{color};\n}\n"
  css_content << css_entry
end

file_path = "colors.css"
File.write(file_path, css_content.join("\n"))
