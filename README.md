# Hierarchical Constant Bandwidth Server - Devel v8

Work-in-progress set of patches for Hierarchical Constant Bandwidth Server (HCBS).

Check [**the main page**](https://github.com/Yurand2000/HCBS-patch/tree/github-workflow) for more information.

### Updates from [version v7](https://github.com/Yurand2000/HCBS-patch/tree/submission-261109-rt-cgroups)

- **261111**
    + Fix invalid runqueue dereference for fair/ext servers offline at boot.
    + Fix invalid NULL struct access in preparation patches.
    + Fix incorrect runqueue pointer acquisition in preparation patches.
    + [MAYBE] Fix invalid NULL struct access in pick_task_rt.
    + Fix missing rq_of_rt_rq update to global_rq_of_rt_rq in statistics functions.
    + Make rt_rq->rq pointer only available with CGROUP_RT_GROUP_SCHED.
    + Fix unused variable warning when CONFIG_LOCKDEP is disabled.

- **261112**
    + Use global runqueue instead of local runqueue for checks in pick_next_pushable_task.
    + Remove dl_bandwidth_enabled check in update_curr_rt.
    + Update task runtime before picking task in rt_server_pick.
    + Fix preemption checks in wakeup_preempt_{dl/rt}, switched_to_{dl/rt}, prio_changed_{dl/rt}.
    + Fix task group dereference in task_is_throttled_rt.
    + Add missing config guards in rt.c code.
    + Rename cpu.rt.effective.local to cpu.rt.max.effective.local
    + Fix reading/writing cpu.rt.max and cpu.rt.max.effective.local on disabled rt group sched.
    + Fix sched_rt_handler_mutex being defined only if CONFIG_SYSCTL is active.
    + Fix kalloc with GFP_KERNEL in irq disabled context.
    + Fix double_lock_balance checks in find_lock_lowest_rt_rq.
    + Fix global and local runqueues in find_lock_lowest_rq.

- **261113**
    + Fix priority comparison and push skip on non-rt donor tasks in pull_rt_rq_task.
    + Stop dl_server on NULL pick before checking for shifts in __pick_task_dl.
    + Return pull status from pull_rt_rq_task to rt_server_pick, return RETRY_TASK if higher priority tasks appeared while the lock was released, and skip pulling with core scheduling enabled.
    + Recheck source server state after double_lock_balance in pull_rt_rq_task.
    + Recheck user permissions with the rq lock held in __sched_setscheduler, and use irqsave locking in user_check_sched_setscheduler.
    + Fix name for start_hrtick_rt when CONFIG_SCHED_HRTICK=n.

### Unresolved issues

- PI-boosting of FAIR tasks by RT tasks in a zero-runtime cgroup would cause starvation. ([Review](https://sashiko.dev/#/patchset/20260608121546.69910-1-yurand2000@gmail.com?part=15))
- **SOLVED**: Single pointer state variables for `rq_to_push_from` and `rq_to_pull_to`. ([Review](https://sashiko.dev/#/patchset/20260608121546.69910-1-yurand2000@gmail.com?part=20))
    + **TO CHECK**: Mentioned in the report, a CPU offline operation would block balanced operations on a offlined runqueue and locking balancing permanently.
- Check push/pull_rt_rq_task high-priority tasks that may be pushed instead of preempting locally. ([Review](https://sashiko.dev/#/patchset/20260608121546.69910-1-yurand2000@gmail.com?part=20))
- Use rto_mask (rt overloaded mask) also inside rt-cgroups and update pull_rt_rq_task accordingly. ([Review](https://sashiko.dev/#/patchset/20260608121546.69910-1-yurand2000@gmail.com?part=20))
- affine_move_task pre-existing issue. ([Review](https://sashiko.dev/#/patchset/20260608121546.69910-1-yurand2000@gmail.com?part=22))
- Cgroups-v1 support has been removed. ([Review](https://sashiko.dev/#/patchset/20260608121546.69910-1-yurand2000@gmail.com?part=16))

### Non-critical issues

- in `affine_move_task` a `rq` pointer is overwritten by `move_queued_task`. The following balance callbacks are therefore executed on the new runqueue rather than the old one. The review asks if not executing the old runqueue's callbacks is an issue. It is not, as those balance callbacks are just executed to prevent the scheduler complaining. ([Review](https://sashiko.dev/#/patchset/20260608121546.69910-1-yurand2000@gmail.com?part=22))

- in `__pick_task_dl` it may happen that a rt-cgroup's server performs a pull operation, returning directly the newly pulled task. The review asks if returning `RETRY_TASK` would be more suitable and prevent possible priority inversions. Since the `dl_server` has nonetheless to be queued for execution, and it is the next schedulable entity, it will be still picked in the next iteration and execute the just pulled task, so no need to defer the operation. ([Review](https://sashiko.dev/#/patchset/20260608121546.69910-1-yurand2000@gmail.com?part=23))

- Cleanup functions moved in sched.h ([Review](https://sashiko.dev/#/patchset/20261109163616.195264-1-yurand2000@gmail.com?part=5)).

### Ignored issues

- Desynchronization of `rq->rd->rto_mask` and `rq->rd->rto_count` in between the preparation patches is irrelevant for the whole patchset, as these issues are nonetheless later addressed ([Review](https://sashiko.dev/#/patchset/20261109163616.195264-1-yurand2000@gmail.com?part=4))

- Issues in preparation patches, addressed later in the series ([Review](https://sashiko.dev/#/patchset/20261109163616.195264-1-yurand2000@gmail.com?part=6)).

- Issues in HCBS structure initialization, addressed later ([Review](https://sashiko.dev/#/patchset/20261109163616.195264-1-yurand2000@gmail.com?part=9)).

- Cleanup API __free() variables which are not initialized at definition ([Review](https://sashiko.dev/#/patchset/20261109163616.195264-1-yurand2000@gmail.com?part=11)).

### Unimplemented features and ideas

- Remove reserving cgroups' bandwidth in the root cgroup, rather allow dynamically to reserve anywhere in the hierarchy, as suggested by [Tejun Heo](https://lore.kernel.org/all/bcedd13fc22cb7ba590791a4c1387ecc@kernel.org). `cpuset` integration will require to reserve the same bandwidth on all cpus for these 'root' cgroups, to simplify the `SCHED_DEADLINE` admission test.

---
**Hierarchical Constant Bandwidth Server**
