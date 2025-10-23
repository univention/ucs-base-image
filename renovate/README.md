# Renovate Presets

This folder contains Renovate presets for the ucs base image.

For more information on shared presets, see the
[common-renovate project](https://git.knut.univention.de/univention/dev/nubus-for-k8s/common-renovate).

## Usage

To use the preset from `renovate/preset.json`, add the following to your
renovate configuration file:

```json
{
  "extends": [
    "local>univention/dev/projects/ucs-base-image//renovate/preset#v0.0.1"
  ]
}
```

Please adjust the version by replacing `v0.0.1` in the example above.
