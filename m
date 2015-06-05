Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:34108 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752139AbbFEQWe (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 5 Jun 2015 12:22:34 -0400
Date: Fri, 5 Jun 2015 18:22:16 +0200
From: Peter Zijlstra <peterz@infradead.org>
To: Petr Mladek <pmladek@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>,
        Tejun Heo <tj@kernel.org>, Ingo Molnar <mingo@redhat.com>,
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
Message-ID: <20150605162216.GK19282@twins.programming.kicks-ass.net>
References: <1433516477-5153-1-git-send-email-pmladek@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1433516477-5153-1-git-send-email-pmladek@suse.cz>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jun 05, 2015 at 05:00:59PM +0200, Petr Mladek wrote:
> Workqueue
> 
> 
> Workqueues are quite popular and many kthreads have already been
> converted into them.
> 
> Work queues allow to split the function into even more pieces and
> reach the common check point more often. It is especially useful
> when a kthread handles more tasks and is woken when some work
> is needed. Then we could queue the appropriate work instead
> of waking the whole kthread and checking what exactly needs
> to be done.
> 
> But there are many kthreads that need to cycle many times
> until some work is finished, e.g. khugepaged, virtio_balloon,
> jffs2_garbage_collect_thread. They would need to queue the
> work item repeatedly from the same work item or between
> more work items. It would be a strange semantic.
> 
> Work queues allow to share the same kthread between more users.
> It helps to reduce the number of running kthreads. It is especially
> useful if you would need a kthread for each CPU.
> 
> But this might also be a disadvantage. Just look into the output
> of the command "ps" and see the many [kworker*] processes. One
> might see this a black hole. If a kworker makes the system busy,
> it is less obvious what the problem is in compare with the old
> "simple" and dedicated kthreads.
> 
> Yes, we could add some debugging tools for work queues but
> it would be another non-standard thing that developers and
> system administrators would need to understand.
> 
> Another thing is that work queues have their own scheduler. If we
> move even more tasks there it might need even more love. Anyway,
> the extra scheduler adds another level of complexity when
> debugging problems.

There's a lot more problems with workqueues:

 - they're not regular tasks and all the task controls don't work on
   them. This means all things scheduler, like cpu-affinity, nice, and
   RT/deadline scheduling policies. Instead there is some half baked
   secondary interface for some of these.

   But this also very much includes things like cgroups, which brings me
   to the second point.

 - its oblivious to cgroups (as it is to RT priority for example) both
   leading to priority inversion. A work enqueued from a deep/limited
   cgroup does not inherit the task's cgroup. Instead this work is ran
   from the root cgroup.

   This breaks cgroup isolation, more significantly so when a large part
   of the actual work is done from workqueues (as some workloads end up
   being). Instead of being able to control the work, it all ends up in
   the root cgroup outside of control.


