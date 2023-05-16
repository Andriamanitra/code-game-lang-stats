update-code-golf-sols:
    curl -o code-golf-sols.json "https://code.golf/scores/all-holes/all-langs/all"

build:
    mkdir -p bin
    crystal build -o "bin/codestats" "src/main.cr"

run:
    ./bin/codestats
