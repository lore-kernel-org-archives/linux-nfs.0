Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50381 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752670AbbFHVOj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 8 Jun 2015 17:14:39 -0400
Date: Mon, 8 Jun 2015 23:13:36 +0200
From: Oleg Nesterov <oleg@redhat.com>
To: Petr Mladek <pmladek@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>,
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
Subject: Re: [RFC PATCH 06/18] signal/kthread: Initial implementation of
	kthread signal handling
Message-ID: <20150608211336.GB24869@redhat.com>
References: <1433516477-5153-1-git-send-email-pmladek@suse.cz> <1433516477-5153-7-git-send-email-pmladek@suse.cz> <20150606215816.GB15591@redhat.com> <20150608135107.GB3135@pathway.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150608135107.GB3135@pathway.suse.cz>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Let me first repeat that I agree that everything is subjective ;)

On 06/08, Petr Mladek wrote:
>
> To be honest, this patch set does _not_ make any big change.

But to me it does because (again, imo) it adds the a) unnecessary
and b) wrong interface.

But yes, yes, I agree that most (all?) of kthread/signal (ab)users
need cleanups. And fixes.

> I think that we should make it independent on the iterant kthread API.

Yes! please. Then we can discuss this again and perhaps reconsider
this API.

So I am going to ignore some parts of your email. I am sleeping,
please let me know if I missed something important ;)

> Well, note that allow_signal() sets some "crazy" value (2) for the
> signal handler. IMHO, we should check for these values and handle
> them reasonably even in kthreads. It will make the code more secure.

Not sure I understand. The crazy "2" value just means that kthread
wants to recieve and dequeue this signal. I agree with the good name
for this hard-coded number in advance.

> > > +
> > > +		/* Run the custom handler if any */
> > > +		if (ka->sa.kthread_sa_handler != KTHREAD_SIG_DFL) {
> > > +			ksig.ka = *ka;
> > > +
> > > +			if (ka->sa.sa_flags & SA_ONESHOT)
> > > +				ka->sa.kthread_sa_handler = KTHREAD_SIG_DFL;
> > > +
> > > +			spin_unlock_irqrestore(&sighand->siglock, flags);
> > > +			/* could run directly for kthreads */
> > > +			ksig.ka.sa.kthread_sa_handler(signr);
> > > +			freezable_cond_resched();
> > > +			goto relock;
> >
> > Well. But for what? A simple "switch (signr)" after kthread_dequeue_signal()
> > can do the same. Or, speaking of kthread_iterant_fn() it can even dequeue the
> > signal and pass it to kti->whatever(signr).
>
> I wanted to make it independent on the iterant API. Also if you want to
> handle more signals, you need even more code, e.g. the cycle,
> cond_resched(). So, I think that some generic helper is useful.

I do not. Contrary, I think this needs more code in the likely case.
Anyway, this API won't have too many users, so I don't even this this
is that important.

> > > +		if (sig_kernel_stop(signr)) {
> > > +			__set_current_state(TASK_STOPPED);
> > > +			spin_unlock_irqrestore(&sighand->siglock, flags);
> > > +			/* Don't run again until woken by SIGCONT or SIGKILL */
> > > +			freezable_schedule();
> > > +			goto relock;
> >
> > Yes this avoids the race with SIGCONT. But as I said we can add another
> > trivial helper which checks JOBCTL_STOP_DEQUEUED. So a kthread can do
> > this itself.
>
> Hmm, the helper would have a strange semantic. You need to take
> sighand->siglock, dequeue the signal (SIGSTOP), and call
> __set_current_state(TASK_STOPPED) before you release the lock.
> But what would happen if the dequeued signal is _not_ SIGSTOP?

Perhaps I missed your point, but no. If you want to handle SIGSTOP
you can do

	signr = kthread_signal_dequeue();
	switch (signr) {
	case SIGSTOP:
		something_else();
		kthread_do_signal_stop();
	...
	}


> I think that we should support only the standard handling of
> SIGSTOP. It is closely related with SIGCONT.

Agreed. If kthread wants to actually sleep in TASK_STOPPED state then
it should know about SIGCONT.

> > To me, SIG_DFL behaviour just makes makes no sense when it comes to
> > kthreads. I do not even think this can simplify the code. Unlike user-
> > space task, kthread can happily dequeue SIGSTOP, so why should we mimic
> > the userspace SIG_DFL logic.
>
> Maybe, we should handle only SIGSTOP

So far I even disagree with SIGSTOP "default" semantics. I simply see
no value.

Oleg.

