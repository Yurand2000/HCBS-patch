# HCBS Distrib
### Create installable packages for the HCBS Patchset

Quick start:

```bash
> sh get_ubuntu_config.sh

> sh containers/ubuntu/build_debpkg_ubuntu_22_04.sh \
    build/config/ubuntu-noble-amd64.config
```

---

Breakdown:

```bash
# get the ubuntu-noble source, and get the config to compile a real-time ubuntu kernel for amd64.
> sh get_ubuntu_config.sh

# This creates the following config file:
> ls build/config
ubuntu-noble-amd64.config
```

```bash
# compile the kernel with the given <CFG> config file. This also takes the config and enables HCBS for it. It generates a debpkg file for easy installation. Usually you want to compile a ubuntu version, thus <CFG> will be a ubuntu related config file.
> sh containers/ubuntu/build_debpkg_ubuntu_22_04.sh <CFG>
```