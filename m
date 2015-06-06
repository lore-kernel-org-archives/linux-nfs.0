Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37849 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932631AbbFFWbC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 6 Jun 2015 18:31:02 -0400
Date: Sun, 7 Jun 2015 00:30:01 +0200
From: Oleg Nesterov <oleg@redhat.com>
To: Jiri Kosina <jkosina@suse.cz>
Cc: Petr Mladek <pmladek@suse.cz>, Andrew Morton <akpm@linux-foundation.org>,
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
Subject: Re: [RFC PATCH 11/18] jffs2: Convert jffs2_gcd_mtd kthread into
	the iterant API
Message-ID: <20150606223001.GA18838@redhat.com>
References: <1433516477-5153-1-git-send-email-pmladek@suse.cz> <1433516477-5153-12-git-send-email-pmladek@suse.cz> <20150606211648.GA15591@redhat.com> <alpine.LNX.2.00.1506062322550.12753@pobox.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <alpine.LNX.2.00.1506062322550.12753@pobox.suse.cz>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 06/06, Jiri Kosina wrote:
>
> On Sat, 6 Jun 2015, Oleg Nesterov wrote:
>
> > Still I personally dislike the new kthread_sigaction() API. I agree,
> > a couple if signal helpers for kthreads make sense. Say,
> >
> > 	void kthread_do_signal_stop(void)
> > 	{
> > 		spin_lock_irq(&curtent->sighand->siglock);
> > 		if (current->jobctl & JOBCTL_STOP_DEQUEUED)
> > 			__set_current_state(TASK_STOPPED);
> > 		spin_unlock_irq(&current->sighand->siglock);
> >
> > 		schedule();
> > 	}
>
> ... not to mention the fact that 'STOP' keyword in relation to kthreads
> has completely different meaning today, which just contributes to overall
> confusion; but that's an independent story.

Yes, agreed.

> > But personally I do not think kthread_do_signal() makes a lot of sense...
>
> Would it be possible for you to elaborate a little bit more why you think
> so ... ?

Please see another email I sent in reply to 06/18.

> I personally don't see a huge principal difference between
> "kthread_signal_dequeue() + kthread_do_signal_{stop,...}" vs. generic
> "kthread_do_signal()" that's just basically completely general and takes
> care of 'everything necessary'.

Then why do we need the new API ?

And I do see the difference. Rightly or not I belive that this API buys
nothing but makes the kthread && signal interaction more complex and
confusing. For no reason.

But!

> That being said, my relationship to signal
> handling code is of course much less intimate compared to yours,

No, no, no, this doesn't matter at all ;)

Yes I do dislike this API. So what? I can be wrong. So if other reviewers
like it I will hate them all ^W^W^W not argure. So please comment. I never
trust myself unless I can technically (try to) prove I am right. In this
case I can't, this is only my feeling.

Oleg.

