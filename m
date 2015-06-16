Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:44248 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756206AbbFPHyS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 16 Jun 2015 03:54:18 -0400
Date: Tue, 16 Jun 2015 09:54:14 +0200
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
Message-ID: <20150616075414.GE3135@pathway.suse.cz>
References: <1433516477-5153-1-git-send-email-pmladek@suse.cz>
 <1433516477-5153-7-git-send-email-pmladek@suse.cz>
 <20150606215816.GB15591@redhat.com>
 <20150608135107.GB3135@pathway.suse.cz>
 <20150608211336.GB24869@redhat.com>
 <20150615131341.GN9409@pathway.suse.cz>
 <20150615191429.GA29727@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150615191429.GA29727@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon 2015-06-15 21:14:29, Oleg Nesterov wrote:
> Ah, understand. You think that we need to take ->siglock in advance
> to avoid the race with SIGCONT?

exactly

> No, we don't. Let me show you the code I suggested again:
> 
> 	void kthread_do_signal_stop(void)
> 	{
> 		spin_lock_irq(&curtent->sighand->siglock);
> 		if (current->jobctl & JOBCTL_STOP_DEQUEUED)
> 			__set_current_state(TASK_STOPPED);
> 		spin_unlock_irq(&current->sighand->siglock);
> 
> 		schedule();
> 	}
> 	
> so you can dequeue_signal() and call kthread_do_signal_stop() without
> holding ->siglock. We can rely on JOBCTL_STOP_DEQUEUED bit. SIGCONT
> clears it, so kthread_do_signal_stop() can't race.

Heureka, I have got it. I have previously missed the meaning of the
JOBCTL_STOP_DEQUEUED bit. Thanks for explanation.

Best Regards,
Petr
