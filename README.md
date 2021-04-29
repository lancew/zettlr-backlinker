# zettlr-backlinker
Tool to create backlinks between files linked in [Zettlr](https://github.com/Zettlr/Zettlr)

## Installation
* Clone the repo
* run `carton install`

## Running
* `carton exec perl backlinks.pl`

## Caveats
* The location of the MD files is hardcoded.

## TODO
* File name warning (catch the file with two spaces)
* Files with no tag?
* Spell checking?
* Can we run this on the zettelkasten REPO as a Github Action?
* What other functionality, best practices for Zettelkastens?

## History
April  2021: Removed the insertion of backlinks as that is considered "harmful".
             Code now simple prints list of files with no incoming or outgoing links.
             Removed Test2::V0 as it seemed to conflict with Test::Mockfile
August 2020: A work in progress, contact Lance Wicks if this is of interest to you.
