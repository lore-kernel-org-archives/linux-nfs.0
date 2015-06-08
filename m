Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:51688 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752366AbbFHNvL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 8 Jun 2015 09:51:11 -0400
Date: Mon, 8 Jun 2015 15:51:07 +0200
From: Petr Mladek <pmladek@suse.cz>
To: Oleg Nesterov <oleg@redhat.com>
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
Message-ID: <20150608135107.GB3135@pathway.suse.cz>
References: <1433516477-5153-1-git-send-email-pmladek@suse.cz>
 <1433516477-5153-7-git-send-email-pmladek@suse.cz>
 <20150606215816.GB15591@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150606215816.GB15591@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat 2015-06-06 23:58:16, Oleg Nesterov wrote:
> On 06/05, Petr Mladek wrote:
> >
> > The main question is how much it should follow POSIX and the signal
> > handling of user space processes. On one hand, we want to be as close
> > as possible.
> 
> Why? Let the kthread decide what it should if it gets, say, SIGSTOP.

I agree that it does not make sense to follow POSIX too much for
kthreads. They are special. Signals can be send from userspace and
userspace should not be able to affect the core kernel services, for
example, to stop or kill some kthreas.

On the other hand, I was surprised how signals were handled in the few
kthreads. It looked like a mess to me. For example, lockd dropped locks
when it got SIGKILL, r8712_cmd_thread() allowed SIGTERM and then just
flushed the signal.

To be honest, this patch set does _not_ make any big change. All
signals are still ignored by default. There is default action
only for SIGSTOP and fatal signals.

On the other hand, it should motivate developers to use the signals
a reasonable way. And if nothing, it will help to handle the signals
correctly without races.


> > Finally, kthread_do_signal() is called on a safe place in the main
> > iterant kthread cycle. Then we will not need any special code for
> > signals when using this kthread API.
> 
> OK, I will not comment other parts of iterant API in this thread.
> 
> But as for signal handling, to me a single kthread_iterant->do_signal()
> callback looks better. Rather than multiple callbacks passed as
> ->kthread_sa_handler.

I think that we should make it independent on the iterant kthread API.
I thought about handling signals also in the kthread worker and
workqueues.

One of the side plans here is to make freezing more reliable. Freezer
already pokes normal processes using a fake signal. The same technique
might be usable also for kthreads. A signal could wake them and
navigate to a safe place (fridge).

Another example is kthread_stop(). It sets some flag, wakes the
kthread, and waits for completion. IMHO, it would be more elegant to
send a signal that would wake the kthread and push it to the safe
place where signals might be handled and where the kthread might
get terminated.

The advantage is that a pending signal will not allow to sleep on
a location that is not safe for the given action (freezing, stopping)
and might skip even more sleeps on the way.


> That single callback can deque a signal and decide what it should do.
> 
> > +	spin_lock_irqsave(&sighand->siglock, flags);
> > +
> > +	if (unlikely(signal->flags & SIGNAL_CLD_MASK)) {
> > +		WARN(1, "there are no parents for kernel threads\n");
> > +		signal->flags &= ~SIGNAL_CLD_MASK;
> > +	}
> > +
> > +	for (;;) {
> > +		struct k_sigaction *ka;
> > +
> > +		signr = dequeue_signal(current, &current->blocked, &ksig.info);
> > +
> > +		if (!signr)
> > +			break;
> > +
> > +		ka = &sighand->action[signr-1];
> > +
> > +		/* Do nothing for ignored signals */
> > +		if (ka->sa.kthread_sa_handler == KTHREAD_SIG_IGN)
> > +			continue;
>
> Again, I agree something like the simple kthread_dequeue_signal() makes
> sense. Say, to drop the ignore signal like this code does. Although I
> do not think this is really important, SIG_IGN is only possible if this
> kthread does something strange. Say, blocks/unblocs the ignored signal.

Yup, I can't find any usecase for this at the moment. I do not resist
on SIG_IGN handling.

I did this only for completness. I thought that any similarity with
the normal userspace handling would be useful: the-least-surprise
approach.

Well, note that allow_signal() sets some "crazy" value (2) for the
signal handler. IMHO, we should check for these values and handle
them reasonably even in kthreads. It will make the code more secure.


> > +
> > +		/* Run the custom handler if any */
> > +		if (ka->sa.kthread_sa_handler != KTHREAD_SIG_DFL) {
> > +			ksig.ka = *ka;
> > +
> > +			if (ka->sa.sa_flags & SA_ONESHOT)
> > +				ka->sa.kthread_sa_handler = KTHREAD_SIG_DFL;
> > +
> > +			spin_unlock_irqrestore(&sighand->siglock, flags);
> > +			/* could run directly for kthreads */
> > +			ksig.ka.sa.kthread_sa_handler(signr);
> > +			freezable_cond_resched();
> > +			goto relock;
> 
> Well. But for what? A simple "switch (signr)" after kthread_dequeue_signal()
> can do the same. Or, speaking of kthread_iterant_fn() it can even dequeue the
> signal and pass it to kti->whatever(signr).

I wanted to make it independent on the iterant API. Also if you want to
handle more signals, you need even more code, e.g. the cycle,
cond_resched(). So, I think that some generic helper is useful.



> > +		if (sig_kernel_ignore(signr))
> > +			continue;
> 
> For what? Why a kthread should unignore (say) SIGWINCH if it is not going
> to react?

I do not resist on this.


> > +		if (sig_kernel_stop(signr)) {
> > +			__set_current_state(TASK_STOPPED);
> > +			spin_unlock_irqrestore(&sighand->siglock, flags);
> > +			/* Don't run again until woken by SIGCONT or SIGKILL */
> > +			freezable_schedule();
> > +			goto relock;
> 
> Yes this avoids the race with SIGCONT. But as I said we can add another
> trivial helper which checks JOBCTL_STOP_DEQUEUED. So a kthread can do
> this itself.

Hmm, the helper would have a strange semantic. You need to take
sighand->siglock, dequeue the signal (SIGSTOP), and call
__set_current_state(TASK_STOPPED) before you release the lock.
But what would happen if the dequeued signal is _not_ SIGSTOP?

I think that we should support only the standard handling of
SIGSTOP. It is closely related with SIGCONT. Both are manipulated
in prepare_signal(). I think that it is nice to share the code here
and dangerous to use it othrewise.


> To me, SIG_DFL behaviour just makes makes no sense when it comes to
> kthreads. I do not even think this can simplify the code. Unlike user-
> space task, kthread can happily dequeue SIGSTOP, so why should we mimic
> the userspace SIG_DFL logic.

Maybe, we should handle only SIGSTOP here and do not mimic the
standard behavior for the other sig_kernel_stop(),
sig_kernel_ignore(), and death signals here. I think
about printing some warning in case that the handler
is not defined.

Best Regards,
Petr


> > +		/* Death signals, but try to terminate cleanly */
> > +		kthread_stop_current();
> > +		__flush_signals(current);
> > +		break;
> 
> The same.
> 
> Oleg.
> 
