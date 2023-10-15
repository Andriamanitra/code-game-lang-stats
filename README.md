# CodeGameLangStats

Fetch and visualize number of solutions per language on various coding problem sites.

## Currently supported sites
* code.golf
* CodinGame
* Codewars
* Exercism
* Leetcode
* atcoder.jp
* Codeforces

Please create an issue if you know of another site that should be added!

## How it works

The application is a web server written in [Crystal](crystal-lang.org/) that uses various APIs to fetch the statistics.
As long as you have [just](https://github.com/casey/just), curl, and Crystal installed this should be all you need to get started:
```
$ git clone https://github.com/Andriamanitra/code-game-lang-stats
$ cd code-game-lang-stats
$ just update-code-golf-sols build
$ just run
```

After you run the above command the app will be available on http://localhost:8080. You will be presented with a simple
form in which you can enter links to profiles on the different supported sites, and a table will be generated.
It should look something like this:
![screenshot of the application](https://github.com/Andriamanitra/code-game-lang-stats/assets/10672443/4eb436e6-3eef-471e-afc2-a34146f4af81)
