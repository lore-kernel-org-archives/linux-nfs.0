Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:33069 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752789AbbFIGKj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 9 Jun 2015 02:10:39 -0400
Date: Tue, 9 Jun 2015 15:10:25 +0900
From: Tejun Heo <tj@kernel.org>
To: Petr Mladek <pmladek@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>,
        Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>,
        Richard Weinberger <richard@nod.at>,
        Steven Rostedt <rostedt@goodmis.org>,
        David Woodhouse <dwmw2@infradead.org>, linux-mtd@lists.infradead.org,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>, linux-nfs@vger.kernel.org,
        Chris Mason <clm@fb.com>,
        "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
        Thomas Gleixner <tglx@linutronix.de>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Jiri Kosina <jkosina@suse.cz>, Borislav Petkov <bp@suse.de>,
        Michal Hocko <mhocko@suse.cz>, live-patching@vger.kernel.org,
        linux-api@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [RFC PATCH 00/18] kthreads/signal: Safer kthread API and signal
 handling
Message-ID: <20150609061025.GU21465@mtj.duckdns.org>
References: <1433516477-5153-1-git-send-email-pmladek@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1433516477-5153-1-git-send-email-pmladek@suse.cz>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello,

On Fri, Jun 05, 2015 at 05:00:59PM +0200, Petr Mladek wrote:
> Workqueue
...
> But there are many kthreads that need to cycle many times
> until some work is finished, e.g. khugepaged, virtio_balloon,
> jffs2_garbage_collect_thread. They would need to queue the
> work item repeatedly from the same work item or between
> more work items. It would be a strange semantic.

Hmm... took a look at balloon and jffs2_garbage_collect_thread and I'm
not not sure about this part of argument.  What's wrong with doing a
single round and requeueing if more rounds are necessary?  There are
quite a few which already behave that way.  It sure adds queueing /
dispatch overhead but I'm skeptical that's gonna be anything
noticeable in vast majority of cases.

> Work queues allow to share the same kthread between more users.
> It helps to reduce the number of running kthreads. It is especially
> useful if you would need a kthread for each CPU.

Unbound workqueues also do NUMA node affinities automatically which
usually is a pretty big win for jobs which process lots of data.
Managing concurrency level for these cases is still cumbersome but
there have been some ideas making that part mostly automatic too.

> But this might also be a disadvantage. Just look into the output
> of the command "ps" and see the many [kworker*] processes. One
> might see this a black hole. If a kworker makes the system busy,
> it is less obvious what the problem is in compare with the old
> "simple" and dedicated kthreads.
>
> Yes, we could add some debugging tools for work queues but
> it would be another non-standard thing that developers and
> system administrators would need to understand.

Yeah, that's an almost inherent drawback of pooling anything.  It'd be
nice to improve visibility into what workers are doing.  sysrq-t has
recently been extended to help debugging but it'd nice to have
visibility into who's consuming how much.

> Another thing is that work queues have their own scheduler. If we
> move even more tasks there it might need even more love. Anyway,
> the extra scheduler adds another level of complexity when
> debugging problems.

That's only true for the concurrency managed percpu workqueues which
shouldn't be used for anything CPU intensive anyway.  I don't see that
getting much more sophiscated than now.  For unbound workqueues, once
a work item starts executing, the worker thread is under the control
of the scheduler.

> kthread_worker
> 
> 
> kthread_worker is similar to workqueues in many ways. You need to
> 
>   + define work functions
>   + define and initialize work structs
>   + queue work items (structs pointing to the functions and data)
> 
> We could repeat the paragraphs about splitting the work
> and sharing the kthread between more users here.
> 
> Well, the kthread_worker implementation is much simpler than
> the one for workqueues. It is more similar to a simple
> kthread. Especially, it uses the system scheduler.
> But it is still more complex that the simple kthread.
> 
> One interesting thing is that kthread_workers add internal work
> items into the queue. They typically use a completion. An example
> is the flush work. see flush_kthread_work(). It is a nice trick
> but you need to be careful. For example, if you would want to
> terminate the kthread, you might want to remove some work item
> from the queue, especially if you need to break a work item that
> is called in a cycle (queues itself). The question is what to do
> with the internal tasks. If you keep them, they might wake up
> sleepers when the work was not really completed. If you remove
> them, the counter part might sleep forever.

You can pretty much align this part of interface with regular
workqueues which has cancel_work_sync().  The only reason it doesn't
have that is because nobody needed it yet.

That said, there sure are cases where dedicated kthreads are necessary
and kthread_worker was added to help those cases to be more
structured.  I think it's nice to keep the API aligned with workqueue
so that users can easily be converted back and forth but if something
which is more aligned to the current kthread usages eases replacing
the original kthread API completely, I'm all for that.

Also, if this one takes off, I don't think we have any need for
kthread_worker.  It should be easy to replace the few kthread_worker
usages to the new API.

Thanks.

-- 
tejun
