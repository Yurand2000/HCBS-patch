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

- **260924**
    + Fix allocation/deallocation code for rt-cgroups.
    + Lock `dl_bandwidth` before accessing at `__dl_overflow` checks.
    + Fix dl_tasks/servers accounting.
    + Fix checks in `wakeup_preempt_rt`.
    + Fix `NULL` dereference in `task_is_throttled_rt`.
    + Fix parent active context check in `__tg_compute_children_bw`.
    + Lock `dl_bandwidth` before accessing at `switched_to_rt`.
    + Use `cpumask_var_t` in `find_lowest_rt_rq`.

### Unresolved issues

- Fix `dl_init_tg` mandatory `rq_pin_lock` bypass. ([Review](https://sashiko.dev/#/patchset/20260608121546.69910-1-yurand2000@gmail.com?part=11))
- The admission test in sched_dl_global_validate and others mix symmetric and asymmetric scaling methodologies. ([Review](https://sashiko.dev/#/patchset/20260608121546.69910-1-yurand2000@gmail.com?part=13))
- PI-boosting of FAIR tasks by RT tasks in a zero-runtime cgroup would cause starvation. ([Review](https://sashiko.dev/#/patchset/20260608121546.69910-1-yurand2000@gmail.com?part=15))
- Cgroups-v1 support has been removed. ([Review](https://sashiko.dev/#/patchset/20260608121546.69910-1-yurand2000@gmail.com?part=16))
- Single pointer state variables for `rq_to_push_from` and `rq_to_pull_to`. ([Review](https://sashiko.dev/#/patchset/20260608121546.69910-1-yurand2000@gmail.com?part=20))
    + Mentioned in the report, a CPU offline operation would block balanced operations on a offlined runqueue and locking balancing permanently.
- Check push/pull_rt_rq_task high priority slip report. ([Review](https://sashiko.dev/#/patchset/20260608121546.69910-1-yurand2000@gmail.com?part=20))
- Use rto_mask (rt overloaded mask) also inside rt-cgroups and update pull_rt_rq_task accordingly. ([Review](https://sashiko.dev/#/patchset/20260608121546.69910-1-yurand2000@gmail.com?part=20))
- affine_move_task pre-existing issue. ([Review](https://sashiko.dev/#/patchset/20260608121546.69910-1-yurand2000@gmail.com?part=22))

### Non-critical issues

- in affine_move_task a rq pointer is overwritten by move_queued_task. The following balance callbacks are therefore executed on the new runqueue rather than the old one. The review asks if not executing the old runqueue's callbacks is an issue. It is not, as those balance callbacks are just executed to prevent the scheduler complaining. ([Review](https://sashiko.dev/#/patchset/20260608121546.69910-1-yurand2000@gmail.com?part=22))


---
**Hierarchical Constant Bandwidth Server**
