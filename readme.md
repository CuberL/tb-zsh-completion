# tb-zsh-completion

> zsh completion script for [taskbook](https://github.com/klaussinani/taskbook)

This is a zsh completion script for the project [taskbook](https://github.com/klaussinani/taskbook), and it can make taskbook‘s operation more fast and convenient.

## Screenshot

![](https://github.com/CuberL/tb-zsh-completion/blob/master/tty.gif?raw=true)

## Requirement

It use [jq](https://stedolan.github.io/jq/) to parse the `storage.json` so you need install [jq](https://stedolan.github.io/jq/) first. 

Of course, you need to install `zsh` too.

## Installation

you just need to put `_tb.sh` to one of your `$fpath`, restart the zsh and it will work.

## Test

Working under:

* macOS Sierra
* Ubuntu 16.04