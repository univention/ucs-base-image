# Changelog

## [0.17.2](https://git.knut.univention.de/univention/components/ucs-base-image/compare/v0.17.1...v0.17.2) (2025-05-09)


### Bug Fixes

* common-ci reference ([6087730](https://git.knut.univention.de/univention/components/ucs-base-image/commit/60877307a31a457d8244b49fad9e5bae7dbc078c))
* update common-ci to main ([686071f](https://git.knut.univention.de/univention/components/ucs-base-image/commit/686071f3de775987d8c9049ec7946f7321652675))

## [0.17.1](https://git.knut.univention.de/univention/components/ucs-base-image/compare/v0.17.0...v0.17.1) (2025-05-09)


### Bug Fixes

* move addlicense pre-commit hook ([c02d6fd](https://git.knut.univention.de/univention/components/ucs-base-image/commit/c02d6fd8f6d037f85085e4982d8bef71b29b0a9b))
* update common-ci to v1.40.4 ([b06bd12](https://git.knut.univention.de/univention/components/ucs-base-image/commit/b06bd127e8b783478c74122939284335c058702c))

## [0.17.0](https://git.knut.univention.de/univention/components/ucs-base-image/compare/v0.16.2...v0.17.0) (2025-05-09)


### Features

* move gitlab-utils image ([e6eb621](https://git.knut.univention.de/univention/components/ucs-base-image/commit/e6eb621256e4ed9aebdee84a780a7ecc39833125))

## [0.16.2](https://git.knut.univention.de/univention/components/ucs-base-image/compare/v0.16.1...v0.16.2) (2025-03-18)


### Bug Fixes

* add 5.2-1 and 5.0-10 to .gitlab-ci.yml ([f61a0ca](https://git.knut.univention.de/univention/components/ucs-base-image/commit/f61a0ca4d9919cfab15fdb06b6966101996d5166))

## [0.16.1](https://git.knut.univention.de/univention/components/ucs-base-image/compare/v0.16.0...v0.16.1) (2025-02-14)


### Bug Fixes

* add date-based tags to the ucs-base-python image ([3ed128d](https://git.knut.univention.de/univention/components/ucs-base-image/commit/3ed128d3803a323c50b51df363a611e6e9c39ccb))

## [0.16.0](https://git.knut.univention.de/univention/components/ucs-base-image/compare/v0.15.0...v0.16.0) (2025-02-14)


### Features

* build a base image with python3.11 preinstalled ([30a6404](https://git.knut.univention.de/univention/components/ucs-base-image/commit/30a640471ab5b8fe3c6540583678d4eb8ee495d1))


### Bug Fixes

* istall usr-is-merged before dist-upgrade because init-system-helpers depends on it ([d5339a3](https://git.knut.univention.de/univention/components/ucs-base-image/commit/d5339a3688e378ef505f4b043daf9b908bd16ad1))

## [0.15.0](https://git.knut.univention.de/univention/components/ucs-base-image/compare/v0.14.0...v0.15.0) (2025-02-07)


### Features

* public mirror for 5.2/5.1 ([aeee5b5](https://git.knut.univention.de/univention/components/ucs-base-image/commit/aeee5b5a069b31537cb9cf4c00ddc497d8d3d809))

## [0.14.0](https://git.knut.univention.de/univention/components/ucs-base-image/compare/v0.13.3...v0.14.0) (2024-12-11)


### Features

* Run "tini" by default in the entrypoint ([fcffc0e](https://git.knut.univention.de/univention/components/ucs-base-image/commit/fcffc0e5847a2f14f2ad33d063db63933a6ffa6b))

## [0.13.3](https://git.knut.univention.de/univention/components/ucs-base-image/compare/v0.13.2...v0.13.3) (2024-10-15)


### Bug Fixes

* Ensure that the date-based tags are only added after the new container images are built ([f5980fa](https://git.knut.univention.de/univention/components/ucs-base-image/commit/f5980fa530a7c6424219529f267702157c45b254)), closes [univention/customers/dataport/team-souvap#880](https://git.knut.univention.de/univention/customers/dataport/team-souvap/issues/880)

## [0.13.2](https://git.knut.univention.de/univention/components/ucs-base-image/compare/v0.13.1...v0.13.2) (2024-09-26)


### Bug Fixes

* drop developer documentation ([fbf5abe](https://git.knut.univention.de/univention/components/ucs-base-image/commit/fbf5abe29620830dc6b24432909889c2fd675ec9))

## [0.13.1](https://git.knut.univention.de/univention/components/ucs-base-image/compare/v0.13.0...v0.13.1) (2024-07-02)


### Bug Fixes

* team name (to trigger version bump) ([5d3ceea](https://git.knut.univention.de/univention/components/ucs-base-image/commit/5d3ceea22992433cfac8b610234aa7e8df66fc7f))

## [0.13.0](https://git.knut.univention.de/univention/components/ucs-base-image/compare/v0.12.0...v0.13.0) (2024-06-18)


### Features

* build 5.0-8 and drop 5.0-6 ([da53c6b](https://git.knut.univention.de/univention/components/ucs-base-image/commit/da53c6b40f736281c55c515db1202a6031a55515))

## [0.12.0](https://git.knut.univention.de/univention/components/ucs-base-image/compare/v0.11.3...v0.12.0) (2024-04-18)


### Features

* Add stage "final-with-packages" into Dockerfile ([e81a379](https://git.knut.univention.de/univention/components/ucs-base-image/commit/e81a3795069cb15c554ed78711928d381066e3f2))

## [0.11.3](https://git.knut.univention.de/univention/components/ucs-base-image/compare/v0.11.2...v0.11.3) (2024-04-17)


### Bug Fixes

* **ci:** add ucs 5.0-7 and remove 5.0-5 ([c308bd9](https://git.knut.univention.de/univention/components/ucs-base-image/commit/c308bd97d12eaa9eb98fb222118a69605fad925d))
* Output logs to stderr instead of stdout ([2520c15](https://git.knut.univention.de/univention/components/ucs-base-image/commit/2520c15e9e9f96d003e000f3a49bb4818fca498c))
* Use updated utility container version 1.20.0 ([5a94af3](https://git.knut.univention.de/univention/components/ucs-base-image/commit/5a94af3388668554e9ff6846971c35656f46202b))

## [0.11.2](https://git.knut.univention.de/univention/components/ucs-base-image/compare/v0.11.1...v0.11.2) (2024-02-16)


### Bug Fixes

* **deps:** update all dependencies to v1.20.1 ([7748e8a](https://git.knut.univention.de/univention/components/ucs-base-image/commit/7748e8a64fd0295228c98c9ba88c3ecfefeb5ffb))

## [0.11.1](https://git.knut.univention.de/univention/components/ucs-base-image/compare/v0.11.0...v0.11.1) (2024-02-14)


### Bug Fixes

* **deps:** update all dependencies ([2193b01](https://git.knut.univention.de/univention/components/ucs-base-image/commit/2193b016c6aa93cc227c8430a38e4ba00978de08))

## [0.11.0](https://git.knut.univention.de/univention/components/ucs-base-image/compare/v0.10.2...v0.11.0) (2024-01-15)


### Features

* **ci:** add jobs for scheduled update check ([6cdd088](https://git.knut.univention.de/univention/components/ucs-base-image/commit/6cdd088f718a0ebedb0d309aa06f0c8ad9992273))

## [0.10.2](https://git.knut.univention.de/univention/components/ucs-base-image/compare/v0.10.1...v0.10.2) (2024-01-15)


### Bug Fixes

* **deps:** add renovate.json ([56183dd](https://git.knut.univention.de/univention/components/ucs-base-image/commit/56183dde70f00108a3862aaadf396b0af23ecefa))

## [0.10.1](https://git.knut.univention.de/univention/components/ucs-base-image/compare/v0.10.0...v0.10.1) (2023-12-28)


### Bug Fixes

* **licensing/ci:** add spdx license headers, add license header checking pre-commit ([b5fc286](https://git.knut.univention.de/univention/components/ucs-base-image/commit/b5fc286aac62f3804a734795797153ed4f5ffeae))

## [0.10.0](https://git.knut.univention.de/univention/components/ucs-base-image/compare/v0.9.1...v0.10.0) (2023-12-18)


### Features

* **ucs-base:** add UCS 5.0-6 ([f0084b6](https://git.knut.univention.de/univention/components/ucs-base-image/commit/f0084b656ea0db129b64396140656223f8380b86))


### Bug Fixes

* **ci:** bump common-ci include from v1.9.9 to v1.12.0 ([d1e9e3e](https://git.knut.univention.de/univention/components/ucs-base-image/commit/d1e9e3eb2a77335539e5b456836185cbc079679f))

## [0.9.1](https://git.knut.univention.de/univention/components/ucs-base-image/compare/v0.9.0...v0.9.1) (2023-12-01)


### Bug Fixes

* **ci:** add missing import job/container-build ([f52eea3](https://git.knut.univention.de/univention/components/ucs-base-image/commit/f52eea3caf4c73e674bbbda78ec2272cb8c2fab7))

## [0.9.0](https://git.knut.univention.de/univention/components/ucs-base-image/compare/v0.8.1...v0.9.0) (2023-11-17)


### Features

* **ci:** update .releaserc, added sbom generation, signing and scanning ([788e063](https://git.knut.univention.de/univention/components/ucs-base-image/commit/788e06339b2ccb6fa118a30ece55755d852652b4))

This changelog documents all notable changes to the `ucs-base` image.


The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## Unreleased

### Added

- Added AGPLv3 license

## 0.7.5 - 2023-10-17

### Fixed

- Preserve /var/run in the final images

## 0.7.4 - 2023-10-16

### Fixed

- Fix issue with /var/run being unlinked for some older software

## 0.7.3 - 2023-10-13

### Changed

- Update README usage example registry to new repository

### Fixed

- Apt cache and lists issue caused some docker builds to fail

## 0.7.2 - 2023-10-11

### Fixed

- Call entrypoint with absolute path, regardless of user's workdir

## 0.7.1 - 2023-10-11

### Changed

- Update image names in readme

### Fixed

- Added deb-src to ucs 5.2 image

## 0.7.0 - 2023-10-10

### Added

- Drop ucs-base-test-5X0-dev in favor of ucs-base-5X0 and ucs-base-dev-5X0 images

## 0.6.1 - 2023-10-09

### Fixed

- Include source repositories in apt

## 0.6.0 - 2023-10-09

### Added

- Add entrypoint script as a plugin point
- Use bash instead of sh
- Add GitLab MR/issue templates
- Add compose target and instructions for running pre-commit

### Documentation

- Describe intended entrypoint usage

### Fixed

- Allow to export variables from entrypoint fragments

## 0.5.1 - 2023-09-21

### Fixed

- Drop checkout branch example 5X0 since they do not exist
- Options first then arguments on example build command

## 0.5.0 - 2023-09-20

### Added

- Added tests for all 5X0 and 50X images

### Fixed

- Usr-is-merged for 520

## 0.4.0 - 2023-09-19

### Added

- Generate 5.2-0 and 5.1-0 images

### Changed

- Changelog [ci skip]

### Documentation

- Changelog introduction and formatting
- Typo

### Fixed

- Target for test images
- Apt dist-update caused issues on 5.2 with usr-merge

## 0.3.0 - 2023-09-19

### Added

- New Dockerfile with speed and size optimizations
- New context and args for building

### Changed

- Make sources.list preference more obvious
- Point to a tag to include common-ci

### Documentation

- Added livehtml

### Fixed

- Semantic-release changelog not generated
- Changelog generation

## 0.1.0 - 2023-07-03

### Added

- Add container "ucs-base"
- Support UCS_VERSION as ARG for "ucs_base"
- Add copier answers file
- Add "docs/decisions" to capture relevant decisions
- Add release job to tag the version via semantic-release
- Add "ucs-base-dev" to aid development with packages from omar

### Changed

- Build container "ucs-base"
- Build ucs-base in a matrix over the ucs versions
- Use ADD to add the key

### Documentation

- Iterate on the README
- Explain tag structure
- Add examples for usage and to develop
- Capture decision about image naming scheme
- Add usage example of "ucs-base"
- Add overview of provided images into the README
- Add usage example of the container ucs-base-dev

## 0.0.0 - 2023-06-30

### Changed

- Initial commit setting up the repository structure

<!-- generated by git-cliff -->
