# Change Log
All notable changes to *diraction* will be documented in this file.
This project adheres to [Semantic Versioning](http://semver.org/).

## [Unreleased][unreleased]

## [0.19.0] - 2022-11-01
- Better support of folder with space in them ([#28])

## [0.18.0] - 2020-10-18
- See ([#26])
  - reaonly option
  - export configurabililty

## [0.17.1] - 2020-08-24
### Changed
- ✍️ Improved completion of subcommands ([#25])
## [0.17.0] - 2020-04-14
### Added
- 🧭 Working non prefix dir completion ([#18])
- 📂 Create missing folder if requested ([#19])
- 💬 Quoted exec ([#20])
- 🥗 Support kebab case names ([#22])

### Changed
- give up on original `scope:` leading commits old convention. (had forgot one more time about them :man_facepalming:)

## [0.16.1] - 2020-04-12
### Changed
- Refreshed CI and set up github actions

## [0.16] - 2019-04-16
### Added
- prefix matching with `:` and `^`

### Changed
- Improved ls/tree completion (`_ls`/`_tree` keeping old behavior)

### Fixed
- Completion of path with leading `-`

## [0.15] - 2017-10-07
### Added
- better completion for commands in a diraction
- fuzzy matching for folder completion `/`
- nested directory completion for folder completion `//`

## [0.14] - 2017-10-05
### Added
- Can now perform action in diraction subdirs
- Adequate completion for these actions
### Changed
- highlight the commands in the helps
## [0.13] - 2017-10-04
### Added
- Ls diractions command now accept pattern as input
- Instructions to install with others package manager than antigen
- Test infrastructure and covering of all notable zsh version from 4.3
## [0.12.x] - 2015-06-04
### Added
- Magic completion EVERYWHERE
### Changed
- Improved subcommand help
- Now support leading `-` for directory in subcommand completion
### Fixed
- Bug fix diractions containing whitespace are now handled correctly
## [0.12] - 2015-05-25
### Added
- Help for all command with `--help` `-h`
- diraction `save` command
- diraction `whitelist` and `blacklist` command

## [0.11] - 2015-05-25
### Added
- introduce a `where` function aliases to `w` and `?`
- Shpec skeleton test

### Fixed
- now completion of folder really ignore files

## [0.10.2] - 2015-03-02
### Added
- completion of whitelisted commands
- messages on completion groups
### Changed
- `ls` and `tree` subcommand can now take options

## [0.10.1] - 2015-03-02
### Fixed
- changelog links
- wrong alias suggestion for `exec`
### Changed
- improved completion help

## [0.10] - 2015-02-27
### Added
- introduce a real Changelog
- basic completion for `diraction` command suite
- advanced completion for `dispatchers` subfolder


## [0.9.1] - 2015-02-17
### Fixed
- fixes for Apple Darwin support (sed options)

## [0.9] - 2015-02-14
### Added
- introduce `servicing hatch` subcommand with `-`, `,`, `_`
- improved subdir feature: warning if subdir does not exist. (making jump int parent anyway).
 -  introduce `/` and `somesubdir` subcommand
### Changed
- hiding of the `'(eval):1:'` error message in interactive mode

## [0.8] - 2014-12-23
### Added
- proper README with examples
- new Header

## [0.7] - 2014-12-17
### Added
- function to check syntax of diraction defun file
- function to check that directory exists or not

## More history digging would be done one day

[#18]: https://github.com/AdrieanKhisbe/diractions/issues/18
[#19]: https://github.com/AdrieanKhisbe/diractions/issues/19
[#20]: https://github.com/AdrieanKhisbe/diractions/issues/20
[#22]: https://github.com/AdrieanKhisbe/diractions/issues/22
[#25]: https://github.com/AdrieanKhisbe/diractions/issues/25
[#26]: https://github.com/AdrieanKhisbe/diractions/issues/26
[#28]: https://github.com/AdrieanKhisbe/diractions/issues/28

[unreleased]: https://github.com/AdrieanKhisbe/diractions/compare/v0.19.1...HEAD
[0.19.0]: https://github.com/AdrieanKhisbe/diractions/compare/v0.18.0...v0.19.0
[0.18.0]: https://github.com/AdrieanKhisbe/diractions/compare/v0.17.1...v0.18.0
[0.17.1]: https://github.com/AdrieanKhisbe/diractions/compare/v0.17.0...v0.17.1
[0.17.0]: https://github.com/AdrieanKhisbe/diractions/compare/v0.16.1...v0.17.0
[0.16.1]: https://github.com/AdrieanKhisbe/diractions/compare/v0.16...v0.16.1
[0.16]: https://github.com/AdrieanKhisbe/diractions/compare/v0.15...v0.16
[0.15]: https://github.com/AdrieanKhisbe/diractions/compare/v0.14...v0.15
[0.14]: https://github.com/AdrieanKhisbe/diractions/compare/v0.13...v0.14
[0.13]: https://github.com/AdrieanKhisbe/diractions/compare/v0.12.4...v0.13
[0.12.x]: https://github.com/AdrieanKhisbe/diractions/compare/v0.12...v0.12.4
[0.12]: https://github.com/AdrieanKhisbe/diractions/compare/v0.11...v0.12
[0.11]: https://github.com/AdrieanKhisbe/diractions/compare/v0.10.2...v0.11
[0.10.2]: https://github.com/AdrieanKhisbe/diractions/compare/v0.10.1...v0.10.2
[0.10.1]: https://github.com/AdrieanKhisbe/diractions/compare/v0.10...v0.10.1
[0.10]: https://github.com/AdrieanKhisbe/diractions/compare/v0.9.1...v0.10
[0.9.1]: https://github.com/AdrieanKhisbe/diractions/compare/v0.9...v0.9.1
[0.9]: https://github.com/AdrieanKhisbe/diractions/compare/v0.8...v0.9
[0.8]: https://github.com/AdrieanKhisbe/diractions/compare/v0.7...v0.8
[0.7]: https://github.com/AdrieanKhisbe/diractions/compare/v0.6.3...v0.7
