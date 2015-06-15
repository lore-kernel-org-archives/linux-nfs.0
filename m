Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:51511 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754143AbbFONNo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 15 Jun 2015 09:13:44 -0400
Date: Mon, 15 Jun 2015 15:13:41 +0200
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
Message-ID: <20150615131341.GN9409@pathway.suse.cz>
References: <1433516477-5153-1-git-send-email-pmladek@suse.cz>
 <1433516477-5153-7-git-send-email-pmladek@suse.cz>
 <20150606215816.GB15591@redhat.com>
 <20150608135107.GB3135@pathway.suse.cz>
 <20150608211336.GB24869@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150608211336.GB24869@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Oleg,

I am sorry for the late reply. I wanted to think more before answering
all the mails.

On Mon 2015-06-08 23:13:36, Oleg Nesterov wrote:
> I do not. Contrary, I think this needs more code in the likely case.
> Anyway, this API won't have too many users, so I don't even this this
> is that important.
> 
> > > > +		if (sig_kernel_stop(signr)) {
> > > > +			__set_current_state(TASK_STOPPED);
> > > > +			spin_unlock_irqrestore(&sighand->siglock, flags);
> > > > +			/* Don't run again until woken by SIGCONT or SIGKILL */
> > > > +			freezable_schedule();
> > > > +			goto relock;
> > >
> > > Yes this avoids the race with SIGCONT. But as I said we can add another
> > > trivial helper which checks JOBCTL_STOP_DEQUEUED. So a kthread can do
> > > this itself.
> >
> > Hmm, the helper would have a strange semantic. You need to take
> > sighand->siglock, dequeue the signal (SIGSTOP), and call
> > __set_current_state(TASK_STOPPED) before you release the lock.
> > But what would happen if the dequeued signal is _not_ SIGSTOP?
> 
> Perhaps I missed your point, but no. If you want to handle SIGSTOP
> you can do
> 

I think that we need to add:

	spin_lock_irq(&sighand->siglock);

> 	signr = kthread_signal_dequeue();
> 	switch (signr) {
> 	case SIGSTOP:
> 		something_else();
> 		kthread_do_signal_stop();
> 	...
> 	}

And if we want to avoid any race, kthread_do_signal_stop() should look like:

void kthread_do_signal_stop(unsigned long flags)
{
	struct sighand_struct *sighand = current->sighand;

	__set_current_state(TASK_STOPPED);
	spin_unlock_irqrestore(&sighand->siglock, flags);
	/* Don't run again until woken by SIGCONT or SIGKILL */
	freezable_schedule();
}

It means that we will have spin_lock() in one function and
spin_unlock() in another one. This is what I meant with
the strange semantic. This is why I think that it might be
cleaner to implement some generic kthread_do_signal() or so
and allow to (re)define/add sigactions via callbacks.

Note that I am not aware of any kthread that would use SIGSTOP
non-standard way.

Anyway, I am going to concentrate on the main structure of the kthread
API and will put the controversial signal handling a side for now.
I will get back to it when converting the few kthreads that use
signals. I will think more about your feedback in the meantime.

Best Regards,
Petr
