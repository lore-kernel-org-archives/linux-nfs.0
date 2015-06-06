Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:60020 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753066AbbFFVco (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 6 Jun 2015 17:32:44 -0400
Date: Sat, 6 Jun 2015 23:32:40 +0200 (CEST)
From: Jiri Kosina <jkosina@suse.cz>
To: Oleg Nesterov <oleg@redhat.com>
cc: Petr Mladek <pmladek@suse.cz>, Andrew Morton <akpm@linux-foundation.org>,
        Tejun Heo <tj@kernel.org>, Ingo Molnar <mingo@redhat.com>,
        Peter Zijlstra <peterz@infradead.org>,
        Richard Weinberger <richard@nod.at>,
        Steven Rostedt <rostedt@goodmis.org>,
        David Woodhouse <dwmw2@infradead.org>, linux-mtd@lists.infradead.org,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>, linux-nfs@vger.kernel.org,
        Chris Mason <clm@fb.com>,
        "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
        Thomas Gleixner <tglx@linutronix.de>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Borislav Petkov <bp@suse.de>, Michal Hocko <mhocko@suse.cz>,
        live-patching@vger.kernel.org, linux-api@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: [RFC PATCH 11/18] jffs2: Convert jffs2_gcd_mtd kthread into the
 iterant API
In-Reply-To: <20150606211648.GA15591@redhat.com>
Message-ID: <alpine.LNX.2.00.1506062322550.12753@pobox.suse.cz>
References: <1433516477-5153-1-git-send-email-pmladek@suse.cz> <1433516477-5153-12-git-send-email-pmladek@suse.cz> <20150606211648.GA15591@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, 6 Jun 2015, Oleg Nesterov wrote:

> Still I personally dislike the new kthread_sigaction() API. I agree,
> a couple if signal helpers for kthreads make sense. Say,
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

... not to mention the fact that 'STOP' keyword in relation to kthreads 
has completely different meaning today, which just contributes to overall 
confusion; but that's an independent story.

> 
> and probably even "int kthread_signal_deque(void)".
> 
> But personally I do not think kthread_do_signal() makes a lot of sense...

Would it be possible for you to elaborate a little bit more why you think 
so ... ?

I personally don't see a huge principal difference between 
"kthread_signal_dequeue() + kthread_do_signal_{stop,...}" vs. generic 
"kthread_do_signal()" that's just basically completely general and takes 
care of 'everything necessary'. That being said, my relationship to signal 
handling code is of course much less intimate compared to yours, so I am 
really curious what particular objections to that interface have.

Thanks a lot,

-- 
Jiri Kosina
SUSE Labs
