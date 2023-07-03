# Container image names

---

- status: final
- date: 2023-06-30

---

## Context

Users of the generated base images need a way to pin down the versions, so that
they can repeat their builds even if new features have been added into the base
images in an incompatible way.


## Decision

The images are tagged according to the following pattern:

```
ucs-base-${UCS_VERSION}:${IMAGE_TAG}
```

- `${UCS_VERSION}` is a value like `504`
- `${IMAGE_TAG}` is a tag generated from the CI run, e.g. `latest`, `branch-example`.


## Consequences

This does force users of the base images to decide which UCS version to follow
since the UCS version is part of the image name itself.

The addition of the `IMAGE_TAG` does allow to communicate the impact of changes
by following the SemVer specification once we start to add version tags into the
repository.


## More information

- SevVer - <https://semver.org/>
