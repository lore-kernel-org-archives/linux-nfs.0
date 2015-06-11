Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pd0-f196.google.com ([209.85.192.196]:34447 "EHLO
	mail-pd0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752726AbbFKWCz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 11 Jun 2015 18:02:55 -0400
Date: Fri, 12 Jun 2015 07:02:46 +0900
From: Tejun Heo <tj@kernel.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Petr Mladek <pmladek@suse.cz>, Andrew Morton <akpm@linux-foundation.org>,
        Oleg Nesterov <oleg@redhat.com>, Ingo Molnar <mingo@redhat.com>,
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
Message-ID: <20150611220246.GE6336@mtj.duckdns.org>
References: <1433516477-5153-1-git-send-email-pmladek@suse.cz>
 <20150605162216.GK19282@twins.programming.kicks-ass.net>
 <20150609061446.GV21465@mtj.duckdns.org>
 <20150610104057.GE3644@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150610104057.GE3644@twins.programming.kicks-ass.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello, Peter.

On Wed, Jun 10, 2015 at 12:40:57PM +0200, Peter Zijlstra wrote:
> > Because there's a pool of them and the workers come and go
> > dynamically.  There's no way around it.  The attributes just have to
> > be per-pool.
> 
> Sure, but there's a few possible ways to still make that work with the
> regular syscall interfaces.
> 
>  1) propagate the change to any one worker to all workers of the same
>     pool
> 
>  2) have a common ancestor task for each pool, and allow changing that.
>     You can combine that with either the propagation like above, or a
>     rule that workers kill themselves if they observe their parent
>     changed (eg. check a attribute sequence count after each work).

Sure, we can build the interface in different ways but that doesn't
really change the backend much which is where bulk of work lies.

I'm not sure having a proxy task is even a better interface.  It is
better in that we'd be able to reuse task based interface but then
we'd end up with the "proxy" tasks, hooking up notifiers from a number
of essentially unrelated input points into the worker pool mechanism
and what's supported and what's not wouldn't be clear either as the
support for various attributes gradually grow.

More importantly, not all pool attributes will be translatable to task
attributes.  There's no way to map things like CPU or NUMA affinity,
concurrency level or mode of concurrency to attributes of a task
without involving a convoluted mapping or an extra side-band
interface.  Given that that's the case in the other direction too (a
lot of task attributes won't translate to pool attributes), I'm not
doubtful there's a lot of benefit to gain from trying to reuse task
interface for pools.

> > cgroup support will surely be added but I'm not sure we can or should
> > do inheritance automatically.  
> 
> I think its a good default to inherit stuff from the task that queued
> it.

While I agree that it'd make sense for certain use cases, I'm not sure
making that a default.  At least for workqueue, a lot of use cases
don't even register in terms of resource usage and they're just
punting to be in the right execution context.  I'm not sure what we'd
be gaining by going full-on w/ inheritance, which will inevitably
involve a fairly large amount of complexity and overhead as it's
likely to reduce the amount of sharing considerably.

Also, a lot of asynchronous executions share some resources - the
execution context itself, synchronization construct and so on.  While
we do cause priority inversion by putting them all into the same
bucket right now, priority inversions caused by blindly putting all
such async executions into separate buckets are likely to be a lot
worse by blocking higher priority executions behind an extremely
resource constrained instance.

> > Using a different API doesn't solve the
> > problem automatically either.  A lot of kthreads are shared
> > system-wide after all.  We'll need an abstraction layer to deal with
> > that no matter where we do it.
> 
> Yes, hardware threads are global, but so is the hardware. Those are not
> a problem provided the thread map 1:1 with the actual devices and do not
> service multiple devices from a single thread.

I'm not sure why hardware is relevant here (especially given that a
lot of devices which matter in terms of performance are heavily
asynchronous), but if you're saying that certain things would be
simpler if we don't pool anything, that is true but I'm quite doubtful
that we can afford dedicated kthreads for every possible purpose at
this point.

> Once you start combining things you start to get all the above problems
> all over again.

Yes, again, the cost of having pools at all.  I'm not disagreeing that
it adds a layer of abstraction and complexity.  I'm saying this is the
cost we need to pay.

Thanks.

-- 
tejun
