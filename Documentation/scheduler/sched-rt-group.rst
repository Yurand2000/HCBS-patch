==========================
Real-Time group scheduling
==========================

.. CONTENTS

   0. WARNING
   1. Overview
     1.1 The problem
     1.2 The solution
   2. The interface
     2.1 System-wide settings
     2.2 Default behaviour
     2.3 Basis for grouping tasks
   3. Future plans


0. WARNING
==========

 Fiddling with these settings can result in an unstable system, the knobs are
 root only and assumes root knows what he is doing.

Most notable:

 * very small values in sched_rt_period_us can result in an unstable
   system when the period is smaller than either the available hrtimer
   resolution, or the time it takes to handle the budget refresh itself.

 * very small values in sched_rt_runtime_us can result in an unstable
   system when the runtime is so small the system has difficulty making
   forward progress (NOTE: the migration thread and kstopmachine both
   are real-time processes).

1. Overview
===========


1.1 The problem
---------------

Real-time scheduling is all about determinism, a group has to be able to rely on
the amount of bandwidth (eg. CPU time) being constant. In order to schedule
multiple groups of real-time tasks, each group must be assigned a fixed portion
of the CPU time available.  Without a minimum guarantee a real-time group can
obviously fall short. A fuzzy upper limit is of no use since it cannot be
relied upon. Which leaves us with just the single fixed portion.

1.2 The solution
----------------

CPU time is divided by means of specifying how much time can be spent running
in a given period. We allocate this "run time" for each real-time group which
the other real-time groups will not be permitted to use.

Each real-time group runs at the same priority as SCHED_DEADLINE, thus they
share and contend the SCHED_DEADLINE allowed bandwidth. Any time not allocated
to a real-time group (and SCHED_DEADLINE tasks) will be used to run both
SCHED_FIFO/SCHED_RR, normal priority tasks (SCHED_OTHER), and SCHED_EXT tasks,
following the usual priority assignments. Any allocated run time not used will
also be picked up by the other scheduling classes, in the same order as before.

Let's consider an example: a frame fixed real-time renderer must deliver 25
frames a second, which yields a period of 0.04s per frame. Now say it will also
have to play some music and respond to input, leaving it with around 80% CPU
time dedicated for the graphics. We can then give this group a run time of 0.8
* 0.04s = 0.032s.

This way the graphics group will have a 0.04s period with a 0.032s run time
limit. Now if the audio thread needs to refill the DMA buffer every 0.005s, but
needs only about 3% CPU time to do so, it can do with a 0.03 * 0.005s =
0.00015s. So this group can be scheduled with a period of 0.005s and a run time
of 0.00015s.

The remaining CPU time will be used for user input and other tasks. Because
real-time tasks have explicitly allocated the CPU time they need to perform
their tasks, buffer underruns in the graphics or audio can be eliminated.

2. The Interface
================


2.1 System wide settings
------------------------

The system wide settings are configured under the /proc virtual file system:

/proc/sys/kernel/sched_rt_period_us:
  The scheduling period that is equivalent to 100% CPU bandwidth.

/proc/sys/kernel/sched_rt_runtime_us:
  A global limit on how much time real-time scheduling may use (SCHED_DEADLINE
  tasks, real-time groups). This is always less or equal to the period_us, as it
  denotes the time allocated from the period_us for the real-time tasks. Without
  CONFIG_RT_GROUP_SCHED enabled, this only serves for admission control of
  deadline tasks. With CONFIG_RT_GROUP_SCHED=y it also signifies the total
  bandwidth available to both real-time groups and deadline tasks.

  * Time is specified in us because the interface is s32. This gives an
    operating range from 1us to about 35 minutes.
  * sched_rt_period_us takes values from 1 to INT_MAX.
  * sched_rt_runtime_us takes values from -1 to sched_rt_period_us.
  * A run time of -1 specifies runtime == period, ie. no limit.
  * sched_rt_runtime_us/sched_rt_period_us > 0.05 inorder to preserve
    bandwidth for fair dl_server. For accurate value check average of
    runtime/period in /sys/kernel/debug/sched/fair_server/cpuX/


2.2 Default behaviour
---------------------

The default values for sched_rt_period_us (1000000 or 1s) and
sched_rt_runtime_us (950000 or 0.95s).  This gives 0.05s to be used by
SCHED_OTHER (non-RT tasks). These defaults were chosen so that a run-away
real-time tasks will not lock up the machine but leave a little time to recover
it.  By setting runtime to -1 you'd get the old behaviour back.

By default no bandwidth is assigned to the root group and new groups get a
period of 0 and a run time of 0. Groups can act as both task runners or just
bandwidth reservation: If a group has some assigned bandwidth and no tasks
running, it is possible to create sub-groups which may use up to the parent's
bandwidth, giving local control over the total allocated bandwidth.

More specifically:

* A group is deemed *live* if it is a leaf group or all of its children have
  runtime 0.
* *Live* groups are the only groups allowed to run real-time tasks. A SCHED_FIFO
  task cannot be migrated in a non-*live* group, neither a task inside this
  group can change scheduling policy to SCHED_FIFO/SCHED_RR if the group is not
  *live*.
* Non-*live* groups are only used for bandwidth reservation.
* Group's bandwidth follow this invariant: the sum of the bandwidths of a
  group's children is always less than or equal to the group's bandwidth.

Real-time group scheduling means you have to assign a portion of total CPU
bandwidth to the group before it will accept real-time tasks. Therefore you will
not be able to run real-time tasks as any user other than root until you have
done that, even if the user has the rights to run processes with real-time
priority!


2.3 Basis for grouping tasks
----------------------------

Enabling CONFIG_RT_GROUP_SCHED lets you explicitly allocate real
CPU bandwidth to task groups.

This uses the cgroup virtual file system and the CPU controller for cgroups.
Enabling the controller for the hierarchy creates two files:
"<cgroup>/cpu.rt_runtime_us" and "<cgroup>/cpu.rt_period_us" to control the CPU
time reserved for each control group.

For more information on working with control groups, you should read
Documentation/admin-guide/cgroup-v1/cgroups.rst as well.

3. Theoretical Background
=========================


 ..  BIG FAT WARNING ******************************************************

 .. warning::

   This section contains a (not-thorough) summary on deadline/hierarchical
   scheduling theory, and how it applies to real-time control groups.
   The reader can "safely" skip to Section 4 if only interested in seeing
   how the scheduling policy can be used. Anyway, we strongly recommend
   to come back here and continue reading (once the urge for testing is
   satisfied :P) to be sure of fully understanding all technical details.

 .. ************************************************************************

The real-time cgroup scheduler is based upon the Hierarchical Constant Bandwidth
Server [1] framework,

3.1 Definitions
---------------

*We borrow the same definitions given in the sched_deadline document, which are
very briefly summarized here, and new ones, needed by the following content, are
added.*

A typical real-time task is composed of a repetition of computation phases (task
instances, or jobs) which are activated on a periodic or sporadic fashion. For
our purposes, real-time tasks are characterized by three parameters:

* Worst Case Execution Time (WCET): the maximum execution time among all jobs.
* Relative Deadline (D): the relative time each job must be completed.
* Inter-Arrival Period (P): the exact/minimum (for periodic/sporadic tasks) time
  between each consecutive job.

3.2 Hierarchical Constant Bandwidth Server (HCBS) [1]
-----------------------------------------------------

3.3 Multiprocessor Periodic Resource (MPR) model [2]
----------------------------------------------------

A Multiprocessor Periodic Resource (MPR) model [2] **u = <Pi, Theta, m'>**
specifies that an identical, unit-capacity multiprocessor platform collectively
provides **Theta** units of resource every **Pi** time units, where the
**Theta** time units are supplied with concurrency at most **m'**.

This theoretical model is one of the many models that can abstract the
interface of our real-time cgroups: let **m'** be the number of CPUs of the
machine, let **Theta** be **m' * <cgroup>/cpu.rt_runtime_us** and **Pi** be
**<cgroup>/cpu.rt_period_us**.

3.4 Schedulability for MPR on global Fixed-Priority
---------------------------------------------------

3.5 From MPR to deadline servers
--------------------------------

Since there exist no algorithm to schedule MPR interfaces, a tecnique was
developed to transform MPR interfaces into periodic tasks, so that a
number of periodic servers which respect the tasks requirements can be used for
the scheduling of the MPR interface and associated tasks.

Let **u = <Pi, Theta, m>** be a MPR interface, let **a = Theta - m * floor(Theta
/ m)**, let **k = floor(a)**. Define a transformation from **u** to a periodic
taskset **Tau_u = { tau_1 = (C_1, D_1, P_1), ..., tau_m' = (C_m', D_m', P_m')
}**, where:

  **tau_1 = ... = tau_k = (floor(Theta / m') + 1, Pi, Pi)**

  **tau_k+1 = (floor(Theta / m') + a - k * floor(a/k), Pi, Pi)**

  **tau_k+2 = ... = tau_m' = (floor(Theta / m'), Pi, Pi)**

This periodic taskset of servers **Tau_u** can be scheduled on any number of
processors with concurrency at most **m'**.

For real-time control groups, it is possible to just consider a slightly more
demanding taskset **Tau_u'**, where each task **tau_i** is defined as follows:

  **tau_i = (ceil(Theta / m'), Pi, Pi)**

3.6 Other models
----------------

There exist many other theoretical models in literature which are used to
describe a hierarchical scheduling framework on multi-core architectures.
Notable examples are the Multi Supply Function (MSF) abstraction [3] and the
Parallel Supply Function (PSF) abstraction [4].

3.7 References
--------------
  1 - L. Abeni, A. Balsini, and T. Cucinotta, “Container-based real-time
      scheduling in the Linux kernel,” SIGBED Rev., vol. 16, no. 3, pp. 33-38,
      Nov. 2019, doi: 10.1145/3373400.3373405.
  2 - A. Easwaran, I. Shin, and I. Lee, “Optimal virtual cluster-based
      multiprocessor scheduling,” Real-Time Syst, vol. 43, no. 1, pp. 25-59,
      Sept. 2009, doi: 10.1007/s11241-009-9073-x.
  3 - E. Bini, G. Buttazzo, and M. Bertogna, “The Multi Supply Function
      Abstraction for Multiprocessors,” in 2009 15th IEEE International
      Conference on Embedded and Real-Time Computing Systems and Applications,
      Aug. 2009, pp. 294-302. doi: 10.1109/RTCSA.2009.39.
  4 - E. Bini, B. Marko, and S. K. Baruah, “The Parallel Supply Function
      Abstraction for a Virtual Multiprocessor,” in Scheduling, S. Albers, S. K.
      Baruah, R. H. Möhring, and K. Pruhs, Eds., in Dagstuhl Seminar Proceedings
      (DagSemProc), vol. 10071. Dagstuhl, Germany: Schloss Dagstuhl -
      Leibniz-Zentrum für Informatik, 2010, pp. 1-14. doi:
      10.4230/DagSemProc.10071.14.

4. Using Real-Time cgroups
==========================

4.1 CGroup Setup
----------------

Of course, real-time control groups require the mounting of the cgroup file
system. We have decided to only support cgroups v2, so make sure you mount the
v2 controller for the cgroup hierarchy.

Additionally the real-time cgroups require the CPU controller for the cgroups to
be enabled::

  # Assume the cgroup file system is mounted at /sys/fs/cgroup
  > echo "+cpu" > /sys/fs/cgroup/cgroup.subtree_control

The CPU controller can only be mounted if there is no SCHED_FIFO/SCHED_RR task
scheduled in any cgroup other than the root control group.

The root control group has no bandwidth allocated by default, so make sure to
allocate some bandwidth so that it can be used by the other cgroups. More on
that in the following section...

4.2 Bandwidth Allocation for groups
-----------------------------------

Allocating bandwidth to a cgroup is a fundamental step to run real-time
workload. The cgroup filesystem exposes two files:

* ``<cgroup>/cpu.rt_runtime_us``: which specifies the cgroups' runtime in
  microseconds.
* ``<cgroup>/cpu.rt_period_us``: which specifies the cgroups' period in
  microseconds.

Both files are readable and writable, and their default value is zero. By
definition, the specified runtime must be always less than or equal to the
period. Additionally, an admission test checks if the bandwidth invariant is
respected (i.e. sum of children's bandwidth <= parent's bandwidth).

The root control group files instead control and reserve the SCHED_DEADLINE
bandwidth allocated to real-time cgroups, since real-time groups compete and
share the same bandwidth allocated to SCHED_DEADLINE tasks.

4.3 Running real-time tasks in groups
-------------------------------------

To run tasks in real-time groups it is just necessary to change a tasks
scheduling policy to SCHED_FIFO/SCHED_RR and migrate it into the group. If the
group is not allowed to run real-time tasks because of incorrect configuration,
either migrating a SCHED_FIFO/SCHED_RR task into the group or changing
scheduling policy to a task already inside the group will fail::

 # assume there is a task of PID 42 running
 # change its scheduling policy to SCHED_FIFO, priority 99
 > chrt -f -p 99 42

 # migrate the task to a cgroup
 > echo 42 > /sys/fs/cgroup/<my-cgroup>/cgroup.procs

4.4 Special case: the root control group
----------------------------------------

The root cgroup is special, compared to the other cgroups, as its tasks are not
managed by the HCBS algorithm, rather they just use the original
SCHED_FIFO/SCHED_RR policies. As mentioned, its bandwidth files are just used to
control how much of the SCHED_DEADLINE bandwidth is allocated to cgroups.

4.5 Guarantees and Special Behaviours
-------------------------------------

Real-time cgroups are run at the same priority level of SCHED_DEADLINE tasks.
Since this is the highest priority scheduling policy, and since the Constant
Bandwidth Server (CBS) enforces that the specified bandwidth requirements for
both groups and tasks cannot be overrun, real-time groups have the same
guarantees that SCHED_DEADLINE tasks have, i.e. they will be necessarily
supplied by the amount of bandwidth requested (whenever the admission tests
pass).

This means that, since SCHED_FIFO/SCHED_RR tasks scheduled in the root control
group are not subject to bandwidth controls, they are run at a lower priority
than the cgroups' counterparts. Nonetheless, a minimum amount of bandwidth, if
reserved, will always be available to run SCHED_FIFO/SCHED_RR workloads in the
root cgroup, while they will be able to use more runtime if any of the
SCHED_DEADLINE tasks or servers use less than their specified amount of
bandwidth. SCHED_OTHER tasks are instead scheduled as normals, at lower priority
than real-time workloads.

5. Future plans
===============

5.1 Multi-runtime HCBS
----------------------
