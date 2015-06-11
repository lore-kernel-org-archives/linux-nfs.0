Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:53100 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750735AbbFKE2c (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 11 Jun 2015 00:28:32 -0400
Date: Thu, 11 Jun 2015 06:28:28 +0200 (CEST)
From: Jiri Kosina <jkosina@suse.cz>
To: Steven Rostedt <rostedt@goodmis.org>
cc: Peter Zijlstra <peterz@infradead.org>, Petr Mladek <pmladek@suse.cz>,
        Andrew Morton <akpm@linux-foundation.org>,
        Oleg Nesterov <oleg@redhat.com>, Tejun Heo <tj@kernel.org>,
        Ingo Molnar <mingo@redhat.com>, Richard Weinberger <richard@nod.at>,
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
Subject: Re: [RFC PATCH 09/18] kthread: Make it easier to correctly sleep in
 iterant kthreads
In-Reply-To: <20150610100729.6a674c15@gandalf.local.home>
Message-ID: <alpine.LNX.2.00.1506110625010.12753@pobox.suse.cz>
References: <1433516477-5153-1-git-send-email-pmladek@suse.cz> <1433516477-5153-10-git-send-email-pmladek@suse.cz> <20150605161021.GJ19282@twins.programming.kicks-ass.net> <20150608134810.3abd862b@gandalf.local.home> <20150610090724.GD3644@twins.programming.kicks-ass.net>
 <20150610100729.6a674c15@gandalf.local.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 10 Jun 2015, Steven Rostedt wrote:

> > Right, and I had not considered that, but it turns out the hung_task
> > detector checks p->state == TASK_UNINTERRUPTIBLE, so TASK_IDLE is indeed
> > safe from that.
> 
> Also, I would assume that TASK_IDLE only makes sense for kernel
> threads, I wonder if we should add an assertion in schedule that
> triggers if a task is scheduling with TASK_IDLE and is not a kernel
> thread (has its own mm?)

For the sake of completnes -- testing for !task_struct->mm is not a 
correct test to find out whether given entity is a kernel thread; kernel 
threads are free to temporarily adopt user struct mm via use_mm() (usually 
for handling AIO on behalf of a particular struct mm).

The correct check is to look at PF_KTHREAD flag in task_struct->flags.

-- 
Jiri Kosina
SUSE Labs
