Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:46133 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752109AbbFJJGc (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 10 Jun 2015 05:06:32 -0400
Date: Wed, 10 Jun 2015 11:05:49 +0200
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
Subject: Re: [RFC PATCH 09/18] kthread: Make it easier to correctly sleep in
 iterant kthreads
Message-ID: <20150610090549.GC3644@twins.programming.kicks-ass.net>
References: <1433516477-5153-1-git-send-email-pmladek@suse.cz>
 <1433516477-5153-10-git-send-email-pmladek@suse.cz>
 <20150605161021.GJ19282@twins.programming.kicks-ass.net>
 <20150608100107.GA3135@pathway.suse.cz>
 <1433763595.1495.35.camel@twins>
 <20150609152526.GB9409@pathway.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150609152526.GB9409@pathway.suse.cz>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jun 09, 2015 at 05:25:26PM +0200, Petr Mladek wrote:
> On Mon 2015-06-08 13:39:55, Peter Zijlstra wrote:
> > On Mon, 2015-06-08 at 12:01 +0200, Petr Mladek wrote:
> > 
> > > Just to be sure. Do you suggest to use TASK_IDLE everywhere in
> > > kthreads or only when the uninterruptible sleep is really needed?
> >
> > Always, only use INTERRUPTIBLE when you're actually interruptible, that
> > is you want signals or such muck to terminate your wait.
> 
> I like that TASK_IDLE clearly describes that the state of the task.
> I am just curious. Is there any particular advantage of using
> uninterruptible sleep over the interruptible one, please?

I think, given how all schedule() calls should be inside a loop testing
their sleep condition, and one has to assume spurious wakeups anyhow,
one can make an argument for removing the distinction.

That said, typically INTERRUPTIBLE means 'capable of handling signals
while waiting for $foo', and as said elsewhere in this thread, kthreads
should not really be having signals.

In that spirit, I think UNINTERRUPTIBLE is the right sleep.

> I ask because making freezable kthreads is quite tricky. You need to
> call try_to_freeze() after each schedule or call freezable_* variants
> of schedule(). I think that it is easy to make a mistake. I wonder if
> it might be more elegant to use interruptible sleep whenever possible,
> send the fake signal also to kthreads and force them moving into some
> location where the freeze is safe and handled.

I don't think that's really a concern here, you have an absolutely
perfect freeze point and freezable_schedule() is fine.
> 
> > > IMHO, we should not use TASK_IDLE in freezable kthreads because
> > > it would break freezing.
> > 
> > How so? The task is IDLE, its not doing anything.
> 
> Well, it might cause the freeze. I have just double checked this
> with ubi_thread(). It calls set_freezable().

> I did the following change:
> 
> diff --git a/drivers/mtd/ubi/wl.c b/drivers/mtd/ubi/wl.c
> index 16214d3d57a4..d528fa5e93ba 100644
> --- a/drivers/mtd/ubi/wl.c
> +++ b/drivers/mtd/ubi/wl.c
> @@ -1428,7 +1428,7 @@ int ubi_thread(void *u)
>                 spin_lock(&ubi->wl_lock);
>                 if (list_empty(&ubi->works) || ubi->ro_mode ||
>                     !ubi->thread_enabled || ubi_dbg_is_bgt_disabled(ubi)) {
> -                       set_current_state(TASK_INTERRUPTIBLE);
> +                       set_current_state(TASK_IDLE);
>                         spin_unlock(&ubi->wl_lock);
>                         schedule();
>                         continue;


> or use in ubi_thread()
> 
> 		freezable_schedule()

This

> or always ignore freezing when the task sets TASK_IDLE.

Can't, because they might get woken up, in which case they need to end
up in the fridge.

> > And this is the arch typical freeze point if ever there was one, you're
> > checking kthread_stop, if we can terminate the kthread, we can certainly
> > get frozen.
> 
> It makes sense. The tasks should be in some sane state when it goes
> into the idle state. I hope that people will not misuse it too much.

Do your utmost bestest to put in as many assertions as you can to avoid
abuse.
