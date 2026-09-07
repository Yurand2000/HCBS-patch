# Hierarchical Constant Bandwidth Server - Devel v7

Work-in-progress set of patches for Hierarchical Constant Bandwidth Server (HCBS).

Check [**the main page**](https://github.com/Yurand2000/HCBS-patch/tree/github-workflow) for more information.

### Updates from [version v6](https://github.com/Yurand2000/HCBS-patch/tree/submission-260608-rt-cgroups)

- [**260907**](https://github.com/Yurand2000/HCBS-patch/tree/rt-cgroups-260907)
    + Rebase patchset over kernel 7.3-rc2
    + HCBS servers must set the `dl_bw_attached` flag.
    + Remove direct access to rq of dl_se for new dl_bw_attached functions.

- **260923**
    + Fix a check for rt_rq overloaded flag in `switched_to_rt`.
    + Remove constness of some helper macros for type consistency.
    + Reintroduce `cpufreq_update_util` when enqueueing/dequeuing RT tasks.

- [**260924**](https://github.com/Yurand2000/HCBS-patch/tree/rt-cgroups-260924)
    + Fix allocation/deallocation code for rt-cgroups.
    + Lock `dl_bandwidth` before accessing at `__dl_overflow` checks.
    + Fix dl_tasks/servers accounting.
    + Fix checks in `wakeup_preempt_rt`.
    + Fix `NULL` dereference in `task_is_throttled_rt`.
    + Fix parent active context check in `__tg_compute_children_bw`.
    + Lock `dl_bandwidth` before accessing at `switched_to_rt`.
    + Use `cpumask_var_t` in `find_lowest_rt_rq`.

- **260925**
    + Rename `cpu.rt.internal` file to `cpu.rt.max.effective.local`.

- [**260929**](https://github.com/Yurand2000/HCBS-patch/tree/rt-cgroups-260929)
    + Fix typos in documentation.
    + Check potentially stale `dl_server` pointer on `pick_task_dl`.
    + Update runqueue clock after a rt-cgroup `dl_server` pull operation.
    + Remove single pointer state variables for `rq_to_push_from` and `rq_to_pull_to`.

- **261002**
    + Add `dl_freq_invariant` flag to opt out of the [frequency invariant behaviour of dl_servers](https://lore.kernel.org/all/20250702021440.2594736-1-kuyo.chang@mediatek.com/).
      This flag is set to `1` only for fair/ext servers for now. HCBS servers (and dl tasks) retain instead the scaling behaviour.

- [**261005**](https://github.com/Yurand2000/HCBS-patch/tree/rt-cgroups-261005)
    + Correcly lock the runqueue in `dl_init_tg`.
    + Fix scaling logic for HCBS servers.
    + Fix admission test in `sched_dl_global_validate` to use asymmetric cpu capacities.

- [**261008**](https://github.com/Yurand2000/HCBS-patch/tree/rt-cgroups-261008)
    + Integrate `cpu` and `cpuset` controllers.

- 261008
    + Fix internal runtime computation rounding errors.

### Unresolved issues

- PI-boosting of FAIR tasks by RT tasks in a zero-runtime cgroup would cause starvation. ([Review](https://sashiko.dev/#/patchset/20260608121546.69910-1-yurand2000@gmail.com?part=15))
- Cgroups-v1 support has been removed. ([Review](https://sashiko.dev/#/patchset/20260608121546.69910-1-yurand2000@gmail.com?part=16))
- SOLVED: Single pointer state variables for `rq_to_push_from` and `rq_to_pull_to`. ([Review](https://sashiko.dev/#/patchset/20260608121546.69910-1-yurand2000@gmail.com?part=20))
    + TO CHECK: Mentioned in the report, a CPU offline operation would block balanced operations on a offlined runqueue and locking balancing permanently.
- Check push/pull_rt_rq_task high-priority tasks that may be pushed instead of preempting locally. ([Review](https://sashiko.dev/#/patchset/20260608121546.69910-1-yurand2000@gmail.com?part=20))
- Use rto_mask (rt overloaded mask) also inside rt-cgroups and update pull_rt_rq_task accordingly. ([Review](https://sashiko.dev/#/patchset/20260608121546.69910-1-yurand2000@gmail.com?part=20))
- affine_move_task pre-existing issue. ([Review](https://sashiko.dev/#/patchset/20260608121546.69910-1-yurand2000@gmail.com?part=22))

### Non-critical issues

- in `affine_move_task` a `rq` pointer is overwritten by `move_queued_task`. The following balance callbacks are therefore executed on the new runqueue rather than the old one. The review asks if not executing the old runqueue's callbacks is an issue. It is not, as those balance callbacks are just executed to prevent the scheduler complaining. ([Review](https://sashiko.dev/#/patchset/20260608121546.69910-1-yurand2000@gmail.com?part=22))

- in `__pick_task_dl` it may happen that a rt-cgroup's server performs a pull operation, returning directly the newly pulled task. The review asks if returning `RETRY_TASK` would be more suitable and prevent possible priority inversions. Since the `dl_server` has nonetheless to be queued for execution, and it is the next schedulable entity, it will be still picked in the next iteration and execute the just pulled task, so no need to defer the operation. ([Review](https://sashiko.dev/#/patchset/20260608121546.69910-1-yurand2000@gmail.com?part=23))


---
**Hierarchical Constant Bandwidth Server**
