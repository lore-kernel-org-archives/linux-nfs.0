Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56012 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753008AbbFFVRt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 6 Jun 2015 17:17:49 -0400
Date: Sat, 6 Jun 2015 23:16:48 +0200
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
Subject: Re: [RFC PATCH 11/18] jffs2: Convert jffs2_gcd_mtd kthread into
	the iterant API
Message-ID: <20150606211648.GA15591@redhat.com>
References: <1433516477-5153-1-git-send-email-pmladek@suse.cz> <1433516477-5153-12-git-send-email-pmladek@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1433516477-5153-12-git-send-email-pmladek@suse.cz>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 06/05, Petr Mladek wrote:
>
> [*] In fact, there was a bug in the original code. It tried to process
>     a non-existing signal when the system was freezing. See the common
>     check for pending signal and freezing.

And another bug afaics:

> -			case SIGSTOP:
> -				jffs2_dbg(1, "%s(): SIGSTOP received\n",
> -					  __func__);
> -				set_current_state(TASK_STOPPED);
> -				schedule();
> -				break;

This is obviously racy, we can miss SIGCONT.

Still I personally dislike the new kthread_sigaction() API. I agree,
a couple if signal helpers for kthreads make sense. Say,

	void kthread_do_signal_stop(void)
	{
		spin_lock_irq(&curtent->sighand->siglock);
		if (current->jobctl & JOBCTL_STOP_DEQUEUED)
			__set_current_state(TASK_STOPPED);
		spin_unlock_irq(&current->sighand->siglock);

		schedule();
	}

and probably even "int kthread_signal_deque(void)".

But personally I do not think kthread_do_signal() makes a lot of sense...

Oleg.

