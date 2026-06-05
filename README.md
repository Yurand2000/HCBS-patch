# Hierarchical Constant Bandwidth Server

Work-in-progress set of patches for Hierarchical Constant Bandwidth Server (HCBS)

### 🚀 Repository Organization
---

The repository work is organized in branches. The main branch, which contains this README, is just used as a user guide for this repository and to schedule github workflows on other branches.

#### Repository branches:
- **github-workflow**: this utils branch.
- **master**: the Linux kernel latest version.
- **rt-cgroups**: the latest WIP for the HCBS patchset.
- **submission-######-rt-cgroups**: HCBS submitted patches, at a given point in time (Example *submission-250929-rt-cgroups* refers to the RFC v3 submission made in September 29th, 2025).
- **rt-cgroups-######**: a backup for the patchset at a given point in time (Example *rt-cgroup-250905* is a backup of September 9th, 2025).

#### Other and Legacy branches:
- **rt-cgroups-devel-######**: Work-in-progress code that is not anymore on the main WIP branch.
- **rt-cgroups-multi-7.0.0-rc4**: Multi-CPU version for kernel version 7.0.0-rc4
- **rt-cgroups-multi-250926**: Multi-CPU version for HCBS, yet to be implemented, latest update on September 26th, 2025.
- **rt-cgroups-tip-######**: HCBS but on the tip branch of the kernel, which is not available as a branch in the github's mirror of the kernel repo.
- **submission-######-{#####}**: Old branches for minor submitted patches
    - **submission-######-fair-bw-fix** for the non-accepted fair bw fix, more at [lore.kernel.org](https://lore.kernel.org/all/20250903114448.664452-1-yurand2000@gmail.com/).
    - **submission-260420-dl-defer-fix** for the [accepted patch](https://lore.kernel.org/all/177926605646.711.13175439777380578041.tip-bot2@tip-bot2/).

### 👤 Authors
---

- Luca Abeni <luca.abeni@santannapisa.it>
- Yuri Andriaccio <yurand2000@gmail.com>
- Alessio Balsini <a.balsini@sssup.it>
- Andrea Parri <parri.andrea@gmail.com>

### 🔧 Current Maintainers
---

- Yuri Andriaccio
- Luca Abeni