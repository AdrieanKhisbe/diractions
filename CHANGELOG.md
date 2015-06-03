# Change Log
All notable changes to *diraction* will be documented in this file.
This project adheres to [Semantic Versioning](http://semver.org/).

## [Unreleased][unreleased]
### Added
- Magic completion EVERYWHERE

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

[unreleased]: https://github.com/AdrieanKhisbe/diractions/compare/v0.12...HEAD
[0.12]: https://github.com/AdrieanKhisbe/diractions/compare/v0.11...v0.12
[0.11]: https://github.com/AdrieanKhisbe/diractions/compare/v0.10.2...v0.11
[0.10.2]: https://github.com/AdrieanKhisbe/diractions/compare/v0.10.1...v0.10.2
[0.10.1]: https://github.com/AdrieanKhisbe/diractions/compare/v0.10...v0.10.1
[0.10]: https://github.com/AdrieanKhisbe/diractions/compare/v0.9.1...v0.10
[0.9.1]: https://github.com/AdrieanKhisbe/diractions/compare/v0.9...v0.9.1
[0.9]: https://github.com/AdrieanKhisbe/diractions/compare/v0.8...v0.9
[0.8]: https://github.com/AdrieanKhisbe/diractions/compare/v0.7...v0.8
[0.7]: https://github.com/AdrieanKhisbe/diractions/compare/v0.6.3...v0.7
