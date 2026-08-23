# Hierarchical Constant Bandwidth Server

[![Static Badge](https://img.shields.io/badge/release-v6-green)](https://lore.kernel.org/all/20260608121546.69910-1-yurand2000@gmail.com/)
[![Static Badge](https://img.shields.io/badge/DOI-10.1109/DCOSS--IoT65416.2025.00070-blue)](https://doi.org/10.1109/DCOSS-IoT65416.2025.00070)

Work-in-progress set of patches for Hierarchical Constant Bandwidth Server (HCBS).

### 📌 What is HCBS?
---

Hierarchical Constant Bandwidth Server (HCBS) is an extension of Linux's [constant bandwidth server](https://docs.kernel.org/scheduler/sched-deadline.html) that allows scheduling multiple **independent, realtime applications** through **control groups**, providing temporal isolation guarantees. HCBS will allow realtime applications inside control groups to be scheduled using the `SCHED_FIFO` and `SCHED_RR` scheduling policies.

In HCBS, control groups are scheduled through `SCHED_DEADLINE`, using the deadline-server mechanism. Each group is associated with a bandwidth reservation (over a specified period), which is distributed among all CPUs. Whenever a control group is deemed runnable, the scheduler is recursively invoked to pick the realtime task to schedule.

The proposed mechanism can be used for various purposes, such as having multiple independent realtime applications on the same machine, guaranteeing that they cannot interfere with each other, and providing access to realtime scheduling policies inside control groups, enforcing bandwidth reservation and control for those policies.

The proposed scheduler aims at replacing and improving upon the already implemented [`RT_GROUP_SCHED`](https://www.kernel.org/doc/html/latest/scheduler/sched-rt-group.html) scheduler, reducing its invasiveness in the scheduler's code and addressing a number of problems... (More at [LWN](https://lwn.net/Articles/1021332/))

### 🚀 Repository Organization
---

The repository work is organized in branches. The main branch, which contains this README, is just used as a user guide for this repository and to schedule github workflows on other branches.

#### Repository branches:
- **github-workflow**: this utils branch.
- **master**: the Linux kernel latest version.
- **rt-cgroups**: the latest WIP for the HCBS patchset.
- **submission-######-rt-cgroups**: HCBS submitted patches, at a given point in time (Example *submission-250929-rt-cgroups* refers to the RFC v3 submission made in September 29th, 2025).
- **rt-cgroups-######**: a backup for the patchset at a given point in time (Example *rt-cgroup-250905* is a backup of September 9th, 2025).
- **rt-cgroups-multi-######**: Latest working versions for the Multi-CPU feature, which may be possibly behind the latest **rt-cgroups** master.

#### Other and Legacy branches:
- **rt-cgroups-devel-######**: Work-in-progress code that is not anymore on the main WIP branch.
- **rt-cgroups-multi-7.0.0-rc4**: Multi-CPU version for kernel version 7.0.0-rc4. It is possibly buggy.
- **rt-cgroups-tip-######**: HCBS but on the tip branch of the kernel, which is not available as a branch in the github's mirror of the kernel repo.
- **submission-######-{#####}**: Old branches for minor submitted patches
    - **submission-######-fair-bw-fix** for the non-accepted fair bw fix, more at [lore.kernel.org](https://lore.kernel.org/all/20250903114448.664452-1-yurand2000@gmail.com/).
    - **submission-260420-dl-defer-fix** for the [accepted patch](https://lore.kernel.org/all/177926605646.711.13175439777380578041.tip-bot2@tip-bot2/).

### 🌐 Online Resources
---

Summaries of its inner working and current development status ([OSPM](https://retis.santannapisa.it/ospm-summit/) Reports):
- 2025 - **Hierarchical CBS with deadline servers** \
  [LWN Article](https://lwn.net/Articles/1021332/), [Video](https://youtu.be/1-s8YU3Rzts?si=VvxLZUz75d75-xmC)
- 2026 - **Hierarchical constant bandwidth server: current state and future challenges** \
  [LWN Article](https://lwn.net/Articles/1078696), [Video](https://youtu.be/HVwaVpXlMS4?si=Ma-vWJKNnsA1ZOBJ)

### 📑 References
---

[![Static Badge](https://img.shields.io/badge/DOI-10.1109/DCOSS--IoT65416.2025.00070-blue)](https://doi.org/10.1109/DCOSS-IoT65416.2025.00070)

Please cite [**Scheduling IoT Applications in Real-Time Control Groups**](https://ieeexplore.ieee.org/abstract/document/11096192):

```bibtex
@inproceedings{11096192,
    author={Andriaccio, Yuri and Abeni, Luca and Torquati, Massimo},
    title={Scheduling IoT Applications in Real-Time Control Groups},
    booktitle={2025 21st International Conference on Distributed Computing in Smart Systems and the Internet of Things (DCOSS-IoT)},
    year={2025},
    pages={01-08},
    doi={10.1109/DCOSS-IoT65416.2025.00070}
}
```

[![Static Badge](https://img.shields.io/badge/DOI-10.1145/3373400.3373405-blue)](https://doi.org/10.1145/3373400.3373405)

Originally based on [**Container-based real-time scheduling in the Linux kernel**](https://dl.acm.org/doi/10.1145/3373400.3373405):

```bibtex
@article{10.1145/3373400.3373405,
    author = {Abeni, Luca and Balsini, Alessio and Cucinotta, Tommaso},
    title = {Container-based real-time scheduling in the Linux kernel},
    year = {2019},
    publisher = {Association for Computing Machinery},
    address = {New York, NY, USA},
    volume = {16},
    number = {3},
    url = {https://doi.org/10.1145/3373400.3373405},
    doi = {10.1145/3373400.3373405},
    journal = {SIGBED Rev.},
    pages = {33–38},
    numpages = {6},
}
```

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
