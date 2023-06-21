# Sitegen

`generate.js` script in this directory is intended for automatically generating static html from codestats.

Make sure the server is running, modify the `PROFILES` variable at the top of `generate.js` file, and execute the script:
```
$ node generate.js > index.html
```

You may also want to customize `template.html` which is used as the template for the output.
