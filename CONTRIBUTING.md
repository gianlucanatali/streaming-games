# Contributing
Changes and improvements are more than welcome! Feel free to fork and open a pull request.

Please follow the house rules to have a bigger chance of your contribution being merged.

## House rules

### How to make changes

 
 - To make changes, create a new branch based on `master` (do not create one from `gh-pages` unless strictly necessary) and make them there, then create a Pull Request to master.  
 `gh-pages` is different from master in that it contains sharing features, analytics and other things that have no direct bearing with the game. `master` is the "pure" version of the game.
 - If you want to modify the docs html, modify the asciidoc files present in `adocs/`: `workshop.adoc` and others. Don't edit the `workshop.html`, because it's supposed to be generated.  
 In order to compile your adoc modifications, you need to use the `asciidoctor` cli installed (install it by running `brew install asciidoctor` if you use homebrew, or see [here for more installation options](https://docs.asciidoctor.org/asciidoctor/latest/install/)   .  
 To run SASS, simply use the following command:  

```

./adocs/build-docs.sh
```



### Changes to 2048 game
See here: [Contribution guidelines for the 2048 game](games/2048/CONTRIBUTING.md)


