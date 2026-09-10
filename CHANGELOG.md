# Changelog

## [0.24.2](https://git.knut.univention.de/univention/dev/projects/ucs-base-image/compare/v0.24.1...v0.24.2) (2026-09-10)


### Reverts

* Revert "ci(container-build): use buildkit for container builds" ([76e95ec](https://git.knut.univention.de/univention/dev/projects/ucs-base-image/commit/76e95eceecc759dea9fea8dbc0fb20c56be9ad5d))
* Revert "ci(container-build): use fakechroot debootstrap variant" ([352a1a5](https://git.knut.univention.de/univention/dev/projects/ucs-base-image/commit/352a1a565a9c948bdbaf78fa47ee15435fb98239))
* Revert "ci(test-ucs-base-usage-example): do not push image on test" ([7ae2b56](https://git.knut.univention.de/univention/dev/projects/ucs-base-image/commit/7ae2b56d8280a39f13b3426629d15b001fc4519d))

## [0.24.1](https://git.knut.univention.de/univention/dev/projects/ucs-base-image/compare/v0.24.0...v0.24.1) (2026-09-10)


### Bug Fixes

* **ci:** write date-based tags only from the scheduled build ([4fe3117](https://git.knut.univention.de/univention/dev/projects/ucs-base-image/commit/4fe311786a278d965d15621d718167866323b804)), closes [#0](https://git.knut.univention.de/univention/dev/projects/ucs-base-image/issues/0)

## [0.24.0](https://git.knut.univention.de/univention/dev/projects/ucs-base-image/compare/v0.23.0...v0.24.0) (2026-09-07)


### Features

* **distroless:** Bazel-built distroless Python base image ([a00a39c](https://git.knut.univention.de/univention/dev/projects/ucs-base-image/commit/a00a39c9af6bc1994b71da4487e59ec556eb9b7c)), closes [#0](https://git.knut.univention.de/univention/dev/projects/ucs-base-image/issues/0)


### Bug Fixes

* **distroless:** link every busybox applet in the shell variant ([eb321d2](https://git.knut.univention.de/univention/dev/projects/ucs-base-image/commit/eb321d22356a9efeac188aa261e834cd48074819)), closes [#0](https://git.knut.univention.de/univention/dev/projects/ucs-base-image/issues/0)

## [0.23.0](https://git.knut.univention.de/univention/dev/projects/ucs-base-image/compare/v0.22.0...v0.23.0) (2026-06-05)


### Features

* add UCS 5.3-0 base image ([fed66b9](https://git.knut.univention.de/univention/dev/projects/ucs-base-image/commit/fed66b92275d9f91fd1f1cbbc4125162d648d3c4)), closes [univention/dev/ucs#3515](https://git.knut.univention.de/univention/dev/ucs/issues/3515)


### Bug Fixes

* remove 530 from the test-ucs-base-usage-example ([86834ec](https://git.knut.univention.de/univention/dev/projects/ucs-base-image/commit/86834ec9c60d285bcec9ab67b0de9eb8d3e89a9f)), closes [univention/dev/ucs#3515](https://git.knut.univention.de/univention/dev/ucs/issues/3515)
* return 0 as errata level if no released errata exists ([ca4a84f](https://git.knut.univention.de/univention/dev/projects/ucs-base-image/commit/ca4a84f49af4e605b252b44f2b698600a9280843)), closes [univention/dev/ucs#3515](https://git.knut.univention.de/univention/dev/ucs/issues/3515)

## [0.22.0](https://git.knut.univention.de/univention/dev/projects/ucs-base-image/compare/v0.21.3...v0.22.0) (2026-05-12)


### Features

* add errata level tracking to UCS base images ([2e4ea66](https://git.knut.univention.de/univention/dev/projects/ucs-base-image/commit/2e4ea66808cfe1218449f50dcda88ce21c65f3c2)), closes [#7](https://git.knut.univention.de/univention/dev/projects/ucs-base-image/issues/7)
