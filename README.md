# Container UCS Base

This project does build a few container images which are prepared so that UCS
packages can be installed.

It started based from a fragment which we saw being repeated over and over
across many of our `Dockerfile` files.

The images are tagged according to the following pattern:

```
ucs-base-${UCS_VERSION}:${IMAGE_TAG}
```

- `${UCS_VERSION}` is a value like `504`
- `${IMAGE_TAG}` is a tag generated from the CI run, e.g. `latest`, `branch-example`.



## Status - Beta

We try to apply the DRY (Don't repeat yourself) principle. It is tagged as
"Beta" since we have only little experience so far with the approach.


## Contact

- Team SouvAP Dev
  - <johannes.bornhold.extern@univention.de>


## Example usage

TODO: Give TL;DR style hint on how to use this.


## Development setup

TODO: Give a TL;DR style hint on how to develop with this.
