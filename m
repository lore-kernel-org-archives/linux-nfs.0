Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:58169 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751993AbbFEPBs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 5 Jun 2015 11:01:48 -0400
From: Petr Mladek <pmladek@suse.cz>
To: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>,
        Tejun Heo <tj@kernel.org>, Ingo Molnar <mingo@redhat.com>,
        Peter Zijlstra <peterz@infradead.org>
Cc: Richard Weinberger <richard@nod.at>, Steven Rostedt <rostedt@goodmis.org>,
        David Woodhouse <dwmw2@infradead.org>, linux-mtd@lists.infradead.org,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>, linux-nfs@vger.kernel.org,
        Chris Mason <clm@fb.com>,
        "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
        Thomas Gleixner <tglx@linutronix.de>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Jiri Kosina <jkosina@suse.cz>, Borislav Petkov <bp@suse.de>,
        Michal Hocko <mhocko@suse.cz>, live-patching@vger.kernel.org,
        linux-api@vger.kernel.org, linux-kernel@vger.kernel.org,
        Petr Mladek <pmladek@suse.cz>
Subject: [RFC PATCH 00/18] kthreads/signal: Safer kthread API and signal handling
Date: Fri,  5 Jun 2015 17:00:59 +0200
Message-Id: <1433516477-5153-1-git-send-email-pmladek@suse.cz>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Kthreads are implemented as an infinite loop. They include check points
for termination, freezer, parking, and even signal handling.

We need to touch all kthreads every time we want to add or
modify the behavior of such checkpoints. It is not easy because
there are several hundreds of kthreads and each of them is
implemented in a slightly different way.

This anarchy brings potentially broken or non-standard behavior.
For example, few kthreads already handle signals a strange way.


This patchset is a _proof-of-concept_ how to improve the situation.


The goal is:


  + enforce cleaner and better maintainable kthreads implementation
    using a new API

  + standardize signal handling in kthreads

  + hopefully solve some existing problems, e.g. with suspend


Why new API?


First, I do not want to add yet another API that would need
to be supported. The aim is to _replace_ the current API.
Well, the old API would need to stay around for some time until
all kthreads are converted.

Second, there are two more existing alternatives. They fulfill
the needs and can be used for some conversions. But IMHO, they
are not well usable in all cases. Let's talk more about them.


Workqueue


Workqueues are quite popular and many kthreads have already been
converted into them.

Work queues allow to split the function into even more pieces and
reach the common check point more often. It is especially useful
when a kthread handles more tasks and is woken when some work
is needed. Then we could queue the appropriate work instead
of waking the whole kthread and checking what exactly needs
to be done.

But there are many kthreads that need to cycle many times
until some work is finished, e.g. khugepaged, virtio_balloon,
jffs2_garbage_collect_thread. They would need to queue the
work item repeatedly from the same work item or between
more work items. It would be a strange semantic.

Work queues allow to share the same kthread between more users.
It helps to reduce the number of running kthreads. It is especially
useful if you would need a kthread for each CPU.

But this might also be a disadvantage. Just look into the output
of the command "ps" and see the many [kworker*] processes. One
might see this a black hole. If a kworker makes the system busy,
it is less obvious what the problem is in compare with the old
"simple" and dedicated kthreads.

Yes, we could add some debugging tools for work queues but
it would be another non-standard thing that developers and
system administrators would need to understand.

Another thing is that work queues have their own scheduler. If we
move even more tasks there it might need even more love. Anyway,
the extra scheduler adds another level of complexity when
debugging problems.


kthread_worker


kthread_worker is similar to workqueues in many ways. You need to

  + define work functions
  + define and initialize work structs
  + queue work items (structs pointing to the functions and data)

We could repeat the paragraphs about splitting the work
and sharing the kthread between more users here.

Well, the kthread_worker implementation is much simpler than
the one for workqueues. It is more similar to a simple
kthread. Especially, it uses the system scheduler.
But it is still more complex that the simple kthread.

One interesting thing is that kthread_workers add internal work
items into the queue. They typically use a completion. An example
is the flush work. see flush_kthread_work(). It is a nice trick
but you need to be careful. For example, if you would want to
terminate the kthread, you might want to remove some work item
from the queue, especially if you need to break a work item that
is called in a cycle (queues itself). The question is what to do
with the internal tasks. If you keep them, they might wake up
sleepers when the work was not really completed. If you remove
them, the counter part might sleep forever.


Conclusion


I think that we still want some rather simple API for kthreads
but it need to be more enforcing that the current simple one.


Content


This patchset is split the following way:

  + 2nd patch: defines basic structure of a new kthread API that
      allows to get most of the checks into a single place

  + 6th patch: proposal of signal handling in kthreads

  + 7th patch: makes kthreads using the new API freezable by default

  + 9th, 16th patches: proposal how to maintain sleeping between
    kthread iterations on a single place

  + 10th, 11th, 12th, 17th, 18th patches: show how the new API
    could be used in some kthreads and hopefully clean them
    a bit

  + the other patches add some helper functions or do some
    related clean up


The patchset touches many areas: kthreads, scheduler, signal handling,
freezer, parking, many subsystems and drivers are using kthreads. This
is why I added so many people into CC.

The patch set can be applied against current Linus' tree for 4.1.0-rc6.


Petr Mladek (18):
  kthread: Allow to call __kthread_create_on_node() with va_list args
  kthread: Add API for iterant kthreads
  kthread: Add kthread_stop_current()
  signal: Rename kernel_sigaction() to kthread_sigaction() and clean it
    up
  freezer/scheduler: Add freezable_cond_resched()
  signal/kthread: Initial implementation of kthread signal handling
  kthread: Make iterant kthreads freezable by default
  kthread: Allow to get struct kthread_iterant from task_struct
  kthread: Make it easier to correctly sleep in iterant kthreads
  jffs2: Remove forward definition of jffs2_garbage_collect_thread()
  jffs2: Convert jffs2_gcd_mtd kthread into the iterant API
  lockd: Convert the central lockd service to kthread_iterant API
  ring_buffer: Use iterant kthreads API in the ring buffer benchmark
  ring_buffer: Allow to cleanly freeze the ring buffer benchmark
    kthreads
  ring_buffer: Allow to exit the ring buffer benchmark immediately
  kthread: Support interruptible sleep with a timeout by iterant
    kthreads
  ring_buffer: Use the new API for a sleep with a timeout in the
    benchmark
  jffs2: Use the new API for a sleep with a timeout

 fs/jffs2/background.c                | 178 ++++++++++------------
 fs/lockd/svc.c                       |  80 +++++-----
 include/linux/freezer.h              |   8 +
 include/linux/kthread.h              |  67 ++++++++
 include/linux/signal.h               |  24 ++-
 include/linux/sunrpc/svc.h           |   2 +
 kernel/kmod.c                        |   2 +-
 kernel/kthread.c                     | 286 +++++++++++++++++++++++++++++++----
 kernel/signal.c                      |  84 +++++++++-
 kernel/trace/ring_buffer_benchmark.c | 110 +++++++-------
 10 files changed, 611 insertions(+), 230 deletions(-)

-- 
1.8.5.6

