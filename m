Return-Path: linux-nfs-owner@vger.kernel.org
Received: from g4t0015.houston.hp.com ([15.201.24.18]:3713 "EHLO
	g4t0015.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1162134Ab3DEQ6N (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 5 Apr 2013 12:58:13 -0400
From: Waiman Long <Waiman.Long@hp.com>
Cc: Waiman Long <Waiman.Long@hp.com>, linux-fsdevel@vger.kernel.org,
        linux-kernel@vger.kernel.org, autofs@vger.kernel.org,
        ceph-devel@vger.kernel.org, linux-cifs@vger.kernel.org,
        samba-technical@lists.samba.org, linux-nfs@vger.kernel.org,
        "Chandramouleeswaran, Aswin" <aswin@hp.com>,
        "Norton, Scott J" <scott.norton@hp.com>,
        Andi Kleen <andi@firstfloor.org>, Dave Chinner <david@fromorbit.com>
Subject: [PATCH v2 0/4] dcache: make dcache more scalable on large system
Date: Fri,  5 Apr 2013 12:57:37 -0400
Message-Id: <1365181061-30787-1-git-send-email-Waiman.Long@hp.com>
To: Alexander Viro <viro@zeniv.linux.org.uk>, Jeff Layton <jlayton@redhat.com>,
        Miklos Szeredi <mszeredi@suse.cz>, Ian Kent <raven@themaw.net>,
        Sage Weil <sage@inktank.com>, Steve French <sfrench@samba.org>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        Eric Paris <eparis@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Change log:

v1->v2
 - Include performance improvement in the AIM7 benchmark results because
   of this patch.
 - Modify dget_parent() to avoid taking the lock, if possible, to further
   improve AIM7 benchmark results.

During some perf-record sessions of the kernel running the high_systime
workload of the AIM7 benchmark, it was found that quite a large portion
of the spinlock contention was due to the perf_event_mmap_event()
function itself. This perf kernel function calls d_path() which,
in turn, call path_get() and dput() indirectly. These 3 functions
were the hottest functions shown in the perf-report output of
the _raw_spin_lock() function in an 8-socket system with 80 cores
(hyperthreading off) with a 3.7.10 kernel with a mutex patch applied:

-  11.97%          reaim  [kernel.kallsyms]     [k] _raw_spin_lock
   - _raw_spin_lock
      + 46.17% d_path
      + 20.31% path_get
      + 19.75% dput

In fact, the output of the "perf record -s -a" (without call-graph)
showed:

 11.73%          reaim  [kernel.kallsyms]     [k] _raw_spin_lock
  8.85%             ls  [kernel.kallsyms]     [k] _raw_spin_lock
  3.97%           true  [kernel.kallsyms]     [k] _raw_spin_lock

Without using the perf monitoring tool, the actual execution profile
will be quite different. In fact, with this patch set applied, the
output of the same "perf record -s -a" command became:

  2.05%          reaim  [kernel.kallsyms]     [k] _raw_spin_lock
  0.30%             ls  [kernel.kallsyms]     [k] _raw_spin_lock
  0.25%           true  [kernel.kallsyms]     [k] _raw_spin_lock

So the time spent on _raw_spin_lock() function went down from 24.55%
to 2.60%. It can be seen that the performance data collected by the
perf-record command can be heavily skewed in some cases on a system
with a large number of CPUs. This set of patches enables the perf
command to give a more accurate and reliable picture of what is really
happening in the system. At the same time, they can also improve the
general performance of systems especially those with a large number
of CPUs.

The d_path() function takes the following two locks:

1. dentry->d_lock [spinlock] from dget()/dget_parent()/dput()
2. rename_lock    [seqlock]  from d_path()

This set of patches were designed to minimize the locking overhead
of these code paths.

The current kernel takes the dentry->d_lock lock whenever it wants to
increment or decrement the d_count reference count. However, nothing
big will really happen until the reference count goes all the way to 1
or 0.  Actually, we don't need to take the lock when reference count
is bigger than 1. Instead, atomic cmpxchg() function can be used to
increment or decrement the count in these situations. For safety,
other reference count update operations have to be changed to use
atomic instruction as well.

The rename_lock is a sequence lock. The d_path() function takes the
writer lock because it needs to traverse different dentries through
pointers to get the full path name. Hence it can't tolerate changes
in those pointers. But taking the writer lock also prevent multiple
d_path() calls to proceed concurrently.

A solution is to introduce a new lock type where there will be a
second type of reader which can block the writers - the sequence
read/write lock (seqrwlock). The d_path() and related functions will
then be changed to take the reader lock instead of the writer lock.
This will allow multiple d_path() operations to proceed concurrently.

Additional performance testing was conducted using the AIM7
benchmark.  It is mainly the first patch that has impact on the AIM7
benchmark. Please see the patch description of the first patch on
more information about the benchmark results.

Incidentally, these patches also have a favorable impact on Oracle
database performance when measured by the Oracle SLOB benchmark.

The following tests with multiple threads were also run on kernels
with and without the patch on an 8-socket 80-core system and a PC
with 4-core i5 processor:

1. find $HOME -size 0b
2. cat /proc/*/maps /proc/*/numa_maps
3. git diff

For both the find-size and cat-maps tests, the performance difference
with hot cache was within a few percentage points and hence within
the margin of error. Single-thread performance was slightly worse,
but multithread performance was generally a bit better. Apparently,
reference count update isn't a significant factor in those tests. Their
perf traces indicates that there was less spinlock content in
functions like dput(), but the function itself ran a little bit longer
on average.

The git-diff test showed no difference in performance. There is a
slight increase in system time compensated by a slight decrease in
user time.

Of the 4 patches, patch 3 is dependent on patch 2. The other 2 patches
are independent can be applied individually.

Signed-off-by: Waiman Long <Waiman.Long@hp.com>

Waiman Long (4):
  dcache: Don't take unnecessary lock in d_count update
  dcache: introduce a new sequence read/write lock type
  dcache: change rename_lock to a sequence read/write lock
  dcache: don't need to take d_lock in prepend_path()

 fs/autofs4/waitq.c        |    6 +-
 fs/ceph/mds_client.c      |    4 +-
 fs/cifs/dir.c             |    4 +-
 fs/dcache.c               |  125 ++++++++++++++++++++---------------------
 fs/namei.c                |    2 +-
 fs/nfs/namespace.c        |    6 +-
 include/linux/dcache.h    |  105 +++++++++++++++++++++++++++++++++--
 include/linux/seqrwlock.h |  137 +++++++++++++++++++++++++++++++++++++++++++++
 kernel/auditsc.c          |    4 +-
 9 files changed, 311 insertions(+), 82 deletions(-)
 create mode 100644 include/linux/seqrwlock.h

